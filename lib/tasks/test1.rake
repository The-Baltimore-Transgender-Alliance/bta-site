require 'json'
require 'pp'
require_relative '../imagegrid'

max_row_w = 12

# task :test1 do
# 	data = JSON.parse(File.read(File.join('config','data.json')))
# 	data = data.map.with_index { |d, i| d.merge({'i' => i})}
# 	cols = data.map { |d, i| ImageGrid::Col.new(d['r'],d['c'], d['i']) }
# 	cols.shuffle!
# 	rows = []
# 	while (cols.length > 0) do
# 		col = cols.shift
# 		row = ImageGrid::Row.new(col.h, max_row_w)
# 		row.append(col)
# 		subset = cols.select {|c| c.h == col.h}
# 		subset.sort!
# 		loop do
# 			s = subset.shift
# 			break if s.nil?
# 			if !row.append(s)
# 				subset.push(s)
# 			end
# 		end
# 		if row.length() != 0
# 			cols.reject! {|c| row.has_col(c)}
# 			rows.push(row)
# 		end
# 	end
# 	rows.sort! {|a,b| b.length() <=> a.length()}
# 	rows.each.with_index {|r,i| r.order = i}
# 	i = 1
# 	rows.each do |r|
# 		r.cols.each do |c|
# 			a = data.detect {|d| d['i'] == c.id}
# 			a['order'] = i
# 			a['offset'] = c.offset
# 			i = i + 1
# 		end
# 	end
#
# 	puts(data.to_json)
# end

# task :test2 do
# 	data = JSON.parse(File.read(File.join('config','data.json')))
# 	data.each do |img|
# 		img['width'] = img['width'].to_i
# 		img['height'] = img['height'].to_i
# 	end
# 	res = ImageGrid.crop_and_grid(data, 12)
# 	puts(res.to_json)
# end
