module ImageGrid
	@@ratios = [
		Rational(3,2),
		Rational(4,3),
		Rational(2,3),
		Rational(3,4),
		Rational(3,1),
		Rational(1,1)
	]
	def ImageGrid.best_fit(numer, denom)
		ratio = Rational(numer, denom)
		diffs = @@ratios.map { |r| { :diff => ((r - ratio).to_f).abs, :ratio => r } }
		diffs.sort_by! { |d| d[:diff] }
		return diffs[0][:ratio]
	end
end
