require 'cloudinary'
require 'http'
require 'json'
require 'yaml'
require 'active_support/core_ext/string'
require_relative 'imagegrid'
require 'pp'

module Gallery
	@@lrg_grid_w = 12
	@@lrg_ratios = [
		Rational(3,2),
		Rational(4,3),
		Rational(2,3),
		Rational(3,4),
		Rational(3,1),
		Rational(1,1)
	]
	@@packing_n_permutations = 1000;
	@@sm_ratios = [
		Rational(1,1),
		Rational(3,2),
		Rational(3,4)
	]

	def Gallery.query_folder(folder)
		max_results = 100
		images = []
		res = Cloudinary::Api.resources(:max_results => max_results, :type => 'upload', :prefix => folder)
		images.push(res['resources'])
		while res.has_key?("next_cursor") do
			res = Cloudinary::Api.resources(:max_results => max_results, :type => 'upload', :next_cursor => res["next_cursor"], :prefix => folder)
			images.push(res['resources'])
		end
		images = images.flatten
		return images
	end

	def Gallery.get_artist(path, folder)
		f_pattern = folder + '/'
		f_start_i = path.rindex(f_pattern)
		f_end_i = f_start_i + f_pattern.length
		substr = path[f_end_i, path.length]
		a_end_i = substr.rindex('/')
		res = path[f_end_i, a_end_i]
		return res
	end

	def Gallery.write_json(data, output_path)
		exists = File.exists? File.expand_path(output_path)
		if (not exists)
			FileUtils.mkdir_p File.dirname(output_path)
		end
		File.open(output_path, "w") { |f| f.write(data.to_json) }
	end

	def Gallery.get_data(input_path)
		data = YAML.load_file(input_path)
		# get the images from cloudinary based on the folders
		data.each { |d| d['images'] = Gallery.query_folder(d['key']) }
		data
	end

	def Gallery.format_data(data)
		# titleize album name -- map and either use the provided title or titleize
		data.each { |d| d['title'] = d['title'] || d['key'].titleize }

		data.map! do |d|
			# determine the artists from the folder path
			d['images'].each { |img| img['artist-key'] = Gallery.get_artist(img['public_id'], d['key']) }
			# get a titleized artist
			d['images'].each { |img| img['artist'] = img['artist-key'].titleize }
			#make sure dims are ints
			d['images'].each {|img| img['width'] = img['width'].to_i}
			d['images'].each {|img| img['height'] = img['height'].to_i}
			d
		end
		data
	end

	def Gallery.get_lrg_grid(data)
		data.map! do |d|
			# determine the best fit aspect ratio for the picture on large screen and get the max crop for the w/h and ratio on lrg screen
			d['images'].map! do |img|
				ratio = ImageGrid.best_fit(Rational(img['width'],img['height']),@@lrg_ratios)
				crop = ImageGrid.crop_to_ratio(ratio, img['width'],img['height'] )
				obj = {'ratio' => ratio, 'ratio_w' => ratio.numerator, 'ratio_h' => ratio.denominator, crop: crop}
				img.merge({'lrg_grid' => obj})
			end
			# get just the ratios to determine the grid
			ratios = d['images'].map {|img| img['lrg_grid']['ratio']}
			# get the grid
			grid_data =  ImageGrid.get_row_col_grid(ratios,@@lrg_grid_w)
			d['images'].each_with_index {|img, i| img['lrg_grid'] = img['lrg_grid'].merge(grid_data[i])}
			d
		end
		data
	end

	def Gallery.get_sm_grid(data)
		data.map! do |d|
			d['images'].map! do |img|
				ratio = ImageGrid.best_fit(Rational(img['width'],img['height']),@@sm_ratios)
				crop = ImageGrid.crop_to_ratio(ratio, img['width'],img['height'] )
				obj = {'ratio' => ratio, 'ratio_w' => ratio.numerator, 'ratio_h' => ratio.denominator, crop: crop}
				img.merge({'sm_grid' => obj})
			end
			heights = d['images'].map {|img| img['sm_grid']['ratio'].denominator}
			grid_data = ImageGrid.get_2_col_packing(heights, @@packing_n_permutations)
			d['images'].each_with_index do |img, i|
				img['sm_grid'] = img['sm_grid'].merge(grid_data['result'][i])
			end
			d
		end
		data
	end

end
