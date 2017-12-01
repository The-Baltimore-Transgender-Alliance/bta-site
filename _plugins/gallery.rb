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
		@@gallery_name = "gallery.json"
		@@albums_rel_dir = "albums"
		@@album_ext = ".html"

		def generate(site)
			gallery = read_gallery_json(site.source)
			data = { 'tag' => 'A big title', 'foo' => 'foobar' }
			gallery.each do |album|
				site.pages << AlbumPage.new(site, site.source, @@albums_rel_dir, album['folder'] + @@album_ext, album)
			end
		end

		def read_gallery_json(base)
			gallery_path = File.join(base, @@data_rel_dir, @@gallery_name)
			if File.exists? File.expand_path(gallery_path)
				file = File.read(gallery_path)
				begin
					data = JSON.parse(file)
				rescue JSON::ParserError => e
					puts(file + "doesn't contain valid json!")
				end
				return data
			else
				puts(gallery_path + " does not exist.")
				return nil
			end
		end
	end
end
