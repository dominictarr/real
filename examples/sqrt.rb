class Sqrt
	def sqrt (val)
		Math.sqrt(val)
	end
end
class Sqrt2
	def search (target,try,hi,lo)
		n_diff = target - (try*try)
#		puts "target: #{target}"
#		puts "n_diff #{n_diff}"
#		puts "try: #{try}"
#		puts "diff #{diff}"

		return try if n_diff.abs < 0.0000001

		if n_diff > 0 then #try is too small
			lo = try	
		else #try is too large
			hi = try	

		end
			search(target,(hi + lo) / 2.0,hi,lo)

	end
	def sqrt (val)
		return 0 if val == 0
		return 1 if val == 1

		(search(val,val/2.0,val,0) * 1000000).round / 1000000.0
	end
end

