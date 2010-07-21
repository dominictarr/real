require 'monkeypatch/module'

class Contractor 

quick_array :contracts,:classes

def new(*args,&block)
	if contracts.first then
		puts "wrapped object"
		w = contracts.first.check(classes.first.allocate)
		#w.is_wrapped
		w.initialize(*args,&block)
	
		w
		return w
	else
		puts "ordinary object"
		return classes.first.new(*args,&block)
	end
end

end
