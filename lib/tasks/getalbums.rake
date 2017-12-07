require 'cloudinary'
require 'http'
require 'json'
require 'yaml'
require 'active_support/core_ext/string'
require_relative '../gallery'
require 'pp'

data_dir = "_data"
config_dir = "config"
input_name = "albums.yml"
output_name = "albums.json"

input_path = File.join(config_dir, input_name)
output_path = File.join(data_dir, output_name)

task :get_albums do
	data = Gallery.get_data(input_path)
	data = Gallery.format_data(data)
	# lrg screen grid
	data = Gallery.get_lrg_grid(data)
	Gallery.write_json(data, output_path)
end
