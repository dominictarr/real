
module StringHelper
	def vals_of(*syms)
		s  = ""
			syms.each{|e|
			m = method(e).call
			if m then
				s << "#{e}:\n#{indent(m.to_s,"  ")}\n"
			end
		}
		s
	end
	def indent(string,indent="\t")#move to a print helper mixin?
		string.split("\n").map{|line| "#{indent}#{line}"}.join("\n")
	end
end