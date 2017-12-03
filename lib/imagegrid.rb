module ImageGrid
	@@ratios = [
		Rational(3,2),
		Rational(4,3),
		Rational(2,3),
		Rational(3,4),
		Rational(3,1),
		Rational(1,1)
	]

	def ImageGrid.best_fit(ratio)
		diffs = @@ratios.map { |r| { :diff => ((r - ratio).to_f).abs, :ratio => r } }
		diffs.sort_by! { |d| d[:diff] }
		return diffs[0][:ratio]
	end

	def ImageGrid.crop_to_ratio(ratio, width, height)
		max = ImageGrid.max_size(ratio, width, height)
		crop_w = width - max[:width]
		crop_h = height - max[:height]
		return {
			:crop_width => max[:width],
			:crop_height => max[:height],
			:crop_factor => max[:factor],
			:crop_left => (crop_w / 2) || 0,
			:crop_right => (crop_w / 2) || 0,
			:crop_top => (crop_h / 2) || 0,
			:crop_bottom => (crop_h / 2) || 0
		}
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
