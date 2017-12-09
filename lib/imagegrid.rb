module ImageGrid

	class Col
		attr_reader :w
		attr_reader :h
		attr_reader :id
		attr_accessor :offset
		def initialize(w,h,id=-1)
			@w = w.to_i
			@h = h.to_i
			@id = id
			@offset = 0
		end
		def <=>(o)
			o.w <=> @w
		end
		def ==(o)
			(o.w == w) && (o.h == h) && (o.id == id)
		end
		def to_s()
			return @id.to_s + ": (" + @w.to_s + ", " + @h.to_s + ")" + " o: " + @offset
		end
	end

	class Row
		attr_reader :cols
		def initialize(h, max_w)
			@h = h.to_i
			@max_w = max_w.to_i
			@cols = []
		end

		def <=>(o)
			o.length() <=> length()
		end

		def length()
			@cols.length == 0 ? 0 : @cols.reduce(0) { |sum,c| sum + c.w }
		end

		def left()
			@max_w - length()
		end

		def full()
			left() == 0
		end

		def fits_w(col)
			left() >= col.w
		end

		def fits_h(col)
			col.h == @h
		end

		def fits(col)
			fits_w(col) && fits_h(col)
		end

		def append(col)
			if fits(col)
				@cols.push(col)
				@cols.each {|c| c.offset = 0}
				@cols[-1].offset = left()
				true
			else
				false
			end
		end

		def has_col(col)
			cols.inject(false) {|r,c| r or (col == c)}
		end
	end

	def ImageGrid.best_fit(wh_ratio, ratios)
		diffs = ratios.map { |r| { :diff => ((r - wh_ratio).to_f).abs, :ratio => r } }
		diffs.sort_by! { |d| d[:diff] }
		return diffs[0][:ratio]
	end

	def ImageGrid.crop_to_ratio(ratio, width, height)
		max = ImageGrid.max_size(ratio, width, height)
		crop_w = width - max[:width]
		crop_h = height - max[:height]
		return {
			:width => max[:width],
			:height => max[:height],
			:factor => max[:factor],
			:left => (crop_w / 2) || 0,
			:right => (crop_w / 2) || 0,
			:top => (crop_h / 2) || 0,
			:bottom => (crop_h / 2) || 0
		}
	end

	def ImageGrid.get_row_col_grid(ratios, row_width)
		cols = ratios.map.with_index { |ratio, i| ImageGrid::Col.new(ratio.numerator,ratio.denominator, i) }
		rows = []
		while(cols.length > 0) do
			col = cols.shift
			row = ImageGrid::Row.new(col.h, row_width)
			row.append(col)
			subset = cols.select {|c| c.h == col.h}
			subset.sort!
			loop do
				s = subset.shift
				break if s.nil?
				row.append(s)
			end
			if row.length() > 0
				cols.reject! {|c| row.has_col(c)}
				rows.push(row)
			end
		end
		rows.sort!
		order = 1
		res = []
		rows.each do |r|
			r.cols.each do |c|
				res[c.id] = {:order => order, :offset => c.offset}
				order = order + 1
			end
		end
		res
	end

	def ImageGrid.get_2_col_packing(heights, n_permutations)
		items = heights.map.with_index {|h, i| {'h' => h, 'index' => i}}

		permutations = Array.new(n_permutations) do |i|
			slice = i.modulo(items.length)
			shuf = items.shuffle
			[shuf[0..slice],shuf[(slice + 1)..-1]]
		end

		scores = permutations.map do |p|
			col1 = p[0].reduce(0) {|sum,item| sum + item['h']}
			col2 = p[1].reduce(0) {|sum,item| sum + item['h']}
			(col1 - col2).abs
		end
		min_score = scores.min
		min_perm = permutations[scores.rindex(min_score)]

		result = []
		min_perm[0].each_with_index do |p, i|
			result[p['index']] = {'col' => 0, 'order' => i}
		end
		min_perm[1].each_with_index do |p, i|
			result[p['index']] = {'col' => 1, 'order' => i}
		end

		{'score' => min_score, 'result' => result}
	end

	private
	def ImageGrid.max_size(ratio, width, height)
		ratio_width = ratio.numerator
		ratio_height = ratio.denominator

		nth_width = ratio.numerator
		nth_height = ratio.denominator

		prev_width = ratio.numerator
		prev_height = ratio.denominator

		nth_factor = 1
		prev_factor = 1
		while (nth_width < width) and (nth_height < height) do
			prev_width = nth_width
			prev_height = nth_height
			prev_factor = nth_factor

			nth_factor = nth_factor + 1

			nth_width = ratio_width * nth_factor
			nth_height = ratio_height * nth_factor
		end

		res = {}

		if (nth_width > width) or (nth_height > height)
			res[:width] = prev_width
			res[:height] = prev_height
			res[:factor] = prev_factor
		else
			res[:width] = nth_width
			res[:height] = nth_height
			res[:factor] = nth_factor
		end

		return res
	end

end
