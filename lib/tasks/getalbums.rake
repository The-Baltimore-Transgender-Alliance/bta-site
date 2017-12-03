require 'cloudinary'
require 'http'
require 'json'
require 'yaml'
require 'active_support/core_ext/string'
require_relative '../imagegrid'
require 'pp'

data_dir = "_data"
config_dir = "config"
input_name = "albums.yml"
output_name = "albums.json"

input_path = File.join(config_dir, input_name)
output_path = File.join(data_dir, output_name)

def query_folder(folder)
	max_results = 7
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

def get_artist(path, folder)
	f_pattern = folder + '/'
	f_start_i = path.rindex(f_pattern)
	f_end_i = f_start_i + f_pattern.length
	substr = path[f_end_i, path.length]
	a_end_i = substr.rindex('/')
	res = path[f_end_i, a_end_i]
	return res
end

task :get_albums do
	data = YAML.load_file(input_path)
	# titleize album name -- map and either use the provided title or titleize
	data.map! { |d| d.merge({ 'title' => d['title'] || d['key'].titleize}) }
	# get the images from cloudinary based on the folders
	data.map! { |d| d.merge({ 'images' => query_folder(d['key']) }) }

	data.map! do |d|
		# determine the artists from the folder path
		d['images'].map! { |i| i.merge({ 'artist-key' => get_artist(i['public_id'], d['key']) })}
		# get a titleized artist
		d['images'].map! { |i| i.merge({ 'artist' => i['artist-key'].titleize }) }
		# determine the best fit aspect ratio for the picture
		d['images'].map! { |i| i.merge({ 'ratio' => ImageGrid.best_fit( Rational(i['width'],i['height']) ) }) }
		# get the max crop for the w/h and ratio
		d['images'].map! { |i| i.merge( ImageGrid.crop_to_ratio( i['ratio'], i['width'],i['height'] ) ) }
		d
	end
	# write to JSON
	exists = File.exists? File.expand_path(output_path)
	if (not exists)
		FileUtils.mkdir_p File.dirname(output_path)
	end
	File.open(output_path, "w") { |f| f.write(data.to_json) }
end
