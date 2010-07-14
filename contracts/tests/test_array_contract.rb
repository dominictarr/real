require 'test/unit'
require 'contracts/array_contract'


class TestArrayContract < Test::Unit::TestCase
include Test::Unit

def test_add
	a = ArrayContract.check([])
	a << :a
	a << :b
	a << :c
	a << []
	a << [:X]
	a << [a]
	
	#aha! i want a log of what contract clauses it abides by.
end

Example = Struct.new(:pre,:post,:returned,:args,:on_method,:name,:contractual)

def

def test_delete

	ary = [:a, 1,3,5,:c,1,nil]
	a = ArrayContract.check(ary)

	a.delete :a
	a.delete 1
	a.delete 36 #delete something which isn't there
end

def get_conditions(contract,example)
	pre = contract.pre_conditions(example.on_method).find{|f| f.name == example.name}
	post = contract.post_conditions(example.on_method).find{|f| f.name == example.name}
	return pre,post
end

def test_get_conditions
		a = [:a]
		e = [Example.new([],[:a],[:a],:a,:'<<',:length_inc,true),
		Example.new([],[:a],[:a],:a,:'<<',:return_self,false),

		Example.new([],a,a,:a,:'<<',:return_self,true),
		Example.new([],[:a],[:a],:a,:'<<',:'include?_new',true),
		Example.new([],[:a],[:a],:a,:'<<',:add_to_end,true)]

	e.each{|e|
		run_example(ArrayContract,e)
	}
end

def run_example (contract,example)
	pp example
	
	pre,post = get_conditions(contract,example)
	puts
	puts "=[#{example.name}]============="
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
	puts (a and b == example.contractual) ? "expected" : "UNEXPECTED!!! was #{!(a and b).nil?} wanted:#{example.contractual}"
	puts "=================="


	a and b == example.contractual
end
def test_example
	e = Example.new([],[:a],[:a],:a,:'<<',:length_inc,true)
	assert run_example(ArrayContract,e), "correct add"
	e = Example.new([],[],[:a],:a,:'<<',:length_inc,false) #not adding the item is against the contract
	assert run_example(ArrayContract,e),"wrong add"


end
end
