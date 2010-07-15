require 'test/unit'
require 'contracts/contract'
require 'monkeypatch/array'
require 'examples/sqrt'

class TestContract < Test::Unit::TestCase
include Test::Unit

def assert_exp (exception,&block)
	begin
		block.call 
		fail "expected #{exception}"
	rescue exception=>e; end
end

def eval_clean(code_213693579235)
	eval(code_213693579235)
end
def test_eval_namespace_context
#this test is for test that the namespace of evaled string is in a clean context.
#this is part of the contract for condition!

#what about hooking local_vairables so the evaled code can't see any outside variables?pu
	contract = Contract.new
	test = contract
	test.pre(:test).block(blk = "proc {local_variables.find {|v| v.length < 15}.nil? and local_variables.length <= 2;}").
		description("clause must be evaluated in clean context - only unlikely values allowed (proc argument + others must be over 15 chars)").
		name(:clean_namespace)
	context = Context.new(self)
	tt = test
	assert_equal nil, tt.check_clause(context,:pre_test,1)

	assert_equal 5,local_variables.length
	assert ! eval(blk).call, "crowed local namespace which return false"
	assert eval_clean(blk).call, "crowed local namespace which return true"
end

def test_simple
	contract = Contract.new
	
	#I am refactoring Contract to use not duplicate methods into 'pre_' and 'post_' variations.

	#this trickest part of this was avoiding namespace collisions calling eval.

	sqrt = contract
	sqrt.pre(:sqrt) {|val| val >= 0}.description("argument must be non negative")

	c = sqrt.pre_conditions(:sqrt)
	assert c
	d = sqrt.clauses[:pre_sqrt]
	assert d
	assert_equal c,d

	sqrt.post(:sqrt).block(blk = "proc {|val| (returned*returned - val).abs < 0.00001}").
		description("work backwards: returned*returned ==(very close) val").
		name(:very_close)

	c = sqrt.post_conditions(:sqrt)
	assert c,"post clauses accessible via post_conditions"
	d = sqrt.clauses[:post_sqrt]
	assert d, "store post conditions in same hash"

	context = Context.new(Sqrt.new)
	sq = sqrt
	assert_equal nil, sq.check_pre(context,:sqrt,1)
	assert_equal nil, sq.check_clause(context,:pre_sqrt,1)

	assert_exp(ContractViolated) { sq.check_pre(context,:sqrt,-1)}
	assert_exp(ContractViolated) { sq.check_clause(context,:pre_sqrt,-1)}


	context.returned(1)
	assert_equal 1,context.returned
	assert_equal nil,sq.check_post(context,:sqrt,1,1)
	context.instance_eval(blk).call(1)
#	context.returned(1)
	assert_equal 1,context.returned
#	pp context
#	assert_equal 1,context.returned
#	context.instance_eval("val = 1; puts 'context:'; pp self; 
#		(returned*returned - val).abs < 0.00001")
	assert_equal nil,sq.check_clause(context,:post_sqrt,1)
#	sqrt

end
end
