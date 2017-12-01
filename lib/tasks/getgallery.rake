require 'cloudinary'
require 'http'
require 'json'
require 'yaml'
require 'active_support/core_ext/string'

data_dir_path = "_data"
config_dir_path = "config"
sheets_config_file = 'sheets.yml'
gallery_config_file = 'gallery.yml'
gallery_output_file = 'gallery.json'

def write_to_file_json(data_path, data)
	exists = File.exists? File.expand_path(data_path)
	if (not exists)
		FileUtils.mkdir_p File.dirname(data_path)
	end
	File.open(data_path, "w") do |f|
		f.write(data.to_json)
	end
end














task :get_gallery do
	config = YAML.load_file(File.join(config_dir_path, gallery_config_file))
	albums = []
	config.each do |c|
		gallery_artists = []
		c['artists'].each do |artist|
			gallery_artists.push({
				:path => (c['folder'] + '/' + artist),
				:artist => (artist.titleize)
			})
		end
		albums.push({ :folder => c['folder'], :gallery_artists => gallery_artists })
	end

	albums = albums.map do |a|
		images = []
		a[:gallery_artists].each do |ga|
			res = Cloudinary::Api.resources(:max_results => 500, :type => 'upload', :prefix => ga[:path])
			res['resources'] = res['resources'].map do |r|
				r[:artist] = ga[:artist]
				r
			end
			images.push(res['resources'])
			while res.has_key?("next_cursor") do
				res = Cloudinary::Api.resources(:max_results => 500, type:"fetch", :next_cursor => res["next_cursor"])
				res['resources'] = res['resources'].map do |r|
					r[:artist] = ga[:artist]
					r
				end
				images.push(res['resources'])
			end
			images = images.flatten
		end
		title = a[:folder].titleize
		{ :folder => a[:folder], :title => title, :images => images }
	end

	data_path = File.join(data_dir_path, gallery_output_file)
	write_to_file_json(data_path, albums)
end
