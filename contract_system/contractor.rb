require 'monkeypatch/module'
class Contracted
	#alias_method  :__instance_eval__,:instance_eval
   instance_methods.reject do |method|
	   /__.*__/ === method or 'instance_eval' == method 
	   #or 'inspect' == method or 'to_s' == method 
	   
	end.each do |method|
		undef_method(method)
	end
	quick_array :__contracts__
  
	def initialize(object,contract)
		@object = object
		@contract = contract
		__contracts__(contract)
	end
	def __check_wrapped__
		true
	end

	def method_missing(m_name, *args, &block)
#		puts "\t#{m_name}"
		h = Context.new(@object)
		h.args(args)
		h.block(block)

		to_call = proc {@object.method(m_name).call(*args, &block)}
	
		@contract.check_contract(h,m_name,to_call)
	end
end


class Contractor 

quick_array :contracts,:classes

def new(*args,&block)
	puts "CONTRACTS #{contracts.inspect}"
	if contracts.first then
		puts "wrapped object"
		w = contracts.first.check(classes.first.allocate)
		raise "e is not wrapped" unless w.__check_wrapped__
		w.initialize(*args,&block)
		return w
	else
		puts "ordinary object"
		return classes.first.new(*args,&block)
	end
end

end
