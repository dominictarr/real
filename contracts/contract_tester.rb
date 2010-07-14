require 'monkeypatch/module'


class ContractTester 
	quick_attr :contract,:examples
Example = Struct.new(:pre,:post,:returned,:args,:on_method,:name,:contractual)

	def initialize
		@examples = []
	end	

	def run_examples
		true
	end

	def run_example(example)
		exmaple
	end
def get_conditions(example)
	pre_m =  :"pre_#{example.on_method}"
	post_m = :"post_#{example.on_method}"
#	puts pre_m
#	puts post_m

	pre_c = contract.clauses[pre_m]
	post_c = contract.clauses[post_m]

#	pp contract.clauses

	pre = pre_c ? pre_c.find{|f| f.name == example.name} : nil
	post = post_c ? post_c.find{|f| f.name == example.name} : nil
#	pp pre
#	pp post

	return pre,post
end
def contractual? bool
	bool ? "Within Contract." : "VIOLATION!"
end
def example(*args)
	examples << e = Example.new(*args)
	run_example e	
end
def run_example (example)
	#pp example
	
	pre,post = get_conditions(example)

	puts
	puts "=[#{example.name}]============="
	args = example.args.is_a?(Array) ? "(#{example.args.join(",")})" : example.args
	puts "#{example.pre}.#{example.on_method}#{args} => #{example.post} (returns: #{example.returned})"

	context = Context.new(example.pre)
		b = a = true
		if pre then
			pre.object (context)
			a = pre.call(*example.args)
		puts pre.description if !a

		end
	context.object(example.post)
	context.returned(example.returned)
	
		if post then
			post.object (context)
			b = post.call(*example.args)
			puts post.description if !a

		end
	puts "Pre->#{contractual?(a)} Post->#{contractual?(b)}"
	if pre.nil? and post.nil? then

	raise "could not find any contracts example \n#{pp_s(example)}"
	end

	if (a and b) == example.contractual then
	puts  "expected"
	else

	puts "UNEXPECTED!!! was #{(a and b)} wanted:#{example.contractual}"
	end
	puts "=================="

	(a and b) == example.contractual
end



end
