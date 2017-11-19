require 'http'
require 'json'

module Jekyll
	class ResourcesDataGenerator < Jekyll::Generator
		@@data_dir_path = "_data"
		@@sheets_data_file = 'sheets.yml'
		@@output_data_file = 'resources.json'
		@@key = ENV['GOOGLE_API_KEY']
		@@spreadsheet_id = ENV['RESOURCE_SHEET_ID'];

		def generate(site)
			@site = site
			@cfg = verify_config()
			if @cfg.nil?
				return
			else
				sheets_data = read_sheets_data()
				resources = retrieve_data(sheets_data)
				write_resources(resources)
			end
		end

		def read_sheets_data()
			data_path = File.join(@@data_dir_path, @@sheets_data_file)
			result = YAML::load(File.open(data_path))
			return result
		end

		def retrieve_data(sheets)
			sheets.each do |sheet|
				url_unparsed = (
					'https://sheets.googleapis.com/v4/spreadsheets/' +
					@@spreadsheet_id + '/values/' +
					sheet['sheet_name'].gsub('/', '%2F') +
					'!' +
					sheet['range'] +
					'?key=' +
					@@key
				).gsub(/ /,"%20")
				url = URI.parse(url_unparsed)

				res = parse_output(HTTP.get(url))
				sheet['header'] = res['header']
				sheet['rows'] = res['rows']
			end
			return sheets
		end

		def parse_output(output)
			json = JSON.parse(output)
			header = json['values'].shift
			rows = json['values']

			rows.each do |row|
				while row.length < header.length do
					row << ''
				end
			end

			return {'header' => header, 'rows' => rows}

		end

		def verify_config()
			if not @site.config.include?('fetch_resources_data')
				STDERR.puts ("WARN: `fetch_resources_data` is not defined in _config.yml. Not generating resources data.")
				return nil
			else
				return true
			end
		end

		def write_resources(data)
			data_path = File.join(@@data_dir_path, @@output_data_file)
			overwrite = @site.config.include?('overwrite_resources_data')
			exists = File.exists? File.expand_path(data_path)
			if exists && (not overwrite)
				STDERR.puts ("WARN: resources data already exists. Not overwriting.")
				return nil
			elsif (not exists)
				FileUtils.mkdir_p File.dirname(data_path)
			end
			File.open(data_path, "w") do |f|
				f.write(data.to_json)
			end
		end
		# url = URI.parse('https://sheets.googleapis.com/v4/spreadsheets/' + sheet_id + '/values/' + 'Organizations!B5:F' + '?key=' + key)

		# puts url

		# puts HTTP.get(url)

	end
end
