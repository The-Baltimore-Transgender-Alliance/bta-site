require 'json'

module Jekyll

	class AlbumPage < Page
		def initialize(site, base, dir, name, data = {})
			@site = site
			@base = base
			@dir = dir
			@name = name

			self.process(@name)

			self.read_yaml(File.join(@base, '_layouts'), 'album.html')

			data.each do |key,value|
				self.data[key] = value
			end
		end
	end

	class AlbumPageGenerator < Generator
		safe true

		@@data_rel_dir = "_data"
		@@data_name = "albums.json"
		@@albums_rel_dir = "albums"
		@@album_ext = ".html"

		def generate(site)
			gallery = read_gallery_json(site.source)
			gallery.each do |album|
				puts('hi')
				site.pages << AlbumPage.new(site, site.source, @@albums_rel_dir, album['key'] + @@album_ext, album)
			end
		end

		def read_gallery_json(base)
			gallery_path = File.join(base, @@data_rel_dir, @@data_name)
			if File.exists? File.expand_path(gallery_path)
				file = File.read(gallery_path)
				begin
					data = JSON.parse(file)
				rescue JSON::ParserError => e
					puts(e)
				end
				return data
			else
				puts(gallery_path + " does not exist.")
				return nil
			end
		end
	end
end
