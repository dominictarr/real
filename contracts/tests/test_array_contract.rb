require 'test/unit'
require 'contracts/array_contract'
require 'contracts/contract_tester'


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

#Example = Struct.new(:pre,:post,:returned,:args,:on_method,:name,:contractual)

def

def test_delete

	ary = [:a, 1,3,5,:c,1,nil]
	a = ArrayContract.check(ary)

	a.delete :a
	a.delete 1
	a.delete 36 #delete something which isn't there
end

def example (*args)
	assert @ct.example *args
end

def test_length
	@ct = ContractTester.new.contract(ArrayContract)
		#(:pre,:post,:returned,:args,:on_method,:name,:contractual)
	example [:a]	,[:a]	,1	,[]	,:length,:length	,true 	#length >= 0
	example []	,[]	,0	,[]	,:length,:length	,true
	example [:a]	,[:a]	,-1	,[]	,:length,:length	,false

	example [],[]	,true	,[]	,:empty?,:empty?	,true 	#empty? == (length == 0)
	example [:a],[:a]	,false	,[]	,:empty?,:empty?	,true 
	example [],[]	,false	,[]	,:empty?,:empty?	,false
	example [:a],[:a]	,true	,[]	,:empty?,:empty?	,false

end

def test_delete
	@ct = ContractTester.new.contract(ArrayContract)
	
	example [:a]	,[:a]	,[:a]	,[:b]	,:delete,:length_may_dec,true 	#stay same
	example [:a,:b],[:a]	,[:a]	,[:b]	,:delete,:length_may_dec,true 	#dec by 1
	example [:a,:a],[]	,[]	,[:a]	,:delete,:length_may_dec,true 	#dec by many
	example []	,[:a]	,[:a,:b],[nil]	,:delete,:length_may_dec,false

	example [:a,:b],[:a]	,:a	,[:b]	,:delete,:deletes_arg	,true 	#deletes the argument
	example [:a,:b],[:a]	,:b	,[:a]	,:delete,:deletes_arg	,false	#deletes something else...

	example [:a,:b],[:a]	,:b	,[:b]	,:delete,:return_arg_or_nil,true	#deletes the argument
	example [:a,:b],[:a]	,nil	,[:c]	,:delete,:return_arg_or_nil,true	#deletes the argument
	example [:a,:b],[:a]	,:c	,[:a]	,:delete,:return_arg_or_nil,false	#deletes something else...
end

def test_append
	a = [:a]
	@ct = ContractTester.new.contract(ArrayContract)
	
	example [],[:a],[:a]	,[:a]	,:'<<'	,:length_inc	,true
	example [],[:a],[:a]	,[:a]	,:'<<'	,:return_self	,false
	example [],a	,a	,[:a]	,:'<<'	,:return_self	,true
	example [],[:a],[:a]	,[:a]	,:'<<'	,:'include?_new',true
	example [],[:a],[:a]	,[:a]	,:'<<'	,:add_to_end	,true
end


def test_example
	@ct = ContractTester.new.contract(ArrayContract)
	
	example([],[:a],[:a],[:a],:'<<',:length_inc,true)
	example([],[],[:a],[:a],:'<<',:length_inc,false)

end
end
