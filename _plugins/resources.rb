# require 'http'
# require 'json'
#
# module Jekyll
# 	class ResourcesDataGenerator < Jekyll::Generator
# 		@@data_dir_path = "_data"
# 		def generate(site)
# 			@site = site
# 			@cfg = verify_config()
# 			if @cfg.nil?
# 				return
# 			else
# 				sheets = get_resources()
# 				write_resources(sheets)
# 			end
# 		end
#
# 		def get_resources()
# 			key = ENV['GOOGLE_API_KEY']
# 			spreadsheet_id = ENV['RESOURCE_SHEET_ID'];
#
# 			sheets = [
# 				{"name" => "Organizations", "id" => '1571211893', "range" => "B4:F"},
# 				{"name" => "Services", "id" => '654170023', "range" => "B4:F"},
# 				{"name" => "Groups", "id" => '626565164', "range" => "B4:F"},
# 				{"name" => "Healthcare", "id" => '1500296117', "range" => "B4:F"},
# 				{"name" => "University Resources", "id" => '514292812', "range" => "B4:F"},
# 				{"name" => "Online Resources / Hotlines", "id" => '1787362336', "range" => "B4:F"},
# 			]
#
# 			sheets.each do |sheet|
# 				url_unparsed = 'https://sheets.googleapis.com/v4/spreadsheets/' + spreadsheet_id + '/values/' + sheet['name'].gsub('/', '%2F') + '!' + sheet['range'] + '?key=' + key
# 				url = URI.parse(url_unparsed.gsub(/ /,'%20'))
# 				puts url
# 				data = JSON.parse(HTTP.get(url))
#
# 				header = data['values'][0]
# 				rows = data['values'].drop(1)
#
# 				sheet['header'] = header
# 				sheet['rows'] = rows
# 			end
# 			return sheets
# 		end
#
# 		def verify_config()
# 			if not @site.config.include?('generate_resources_data')
# 				STDERR.puts ("WARN: `generate_resources_data` is not defined in _config.yml. Not generating resources data.")
# 				return nil
# 			else
# 				return true
# 			end
# 		end
#
# 		def write_resources(data)
# 			path = File.join(@@data_dir_path, 'resources' + '.json')
# 			puts path
# 			# if not File.exists? File.dirname(path)
# 			# 	FileUtils.mkdir_p File.dirname(path)
# 			# end
# 			# File.open(path, "w") do |f|
# 			# 	f.write(data.to_json)
# 			end
# 		end
# 		# url = URI.parse('https://sheets.googleapis.com/v4/spreadsheets/' + sheet_id + '/values/' + 'Organizations!B5:F' + '?key=' + key)
#
# 		# puts url
#
# 		# puts HTTP.get(url)
#
# 	end
# end
