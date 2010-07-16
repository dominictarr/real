require 'test/unit'
require 'contracts/contract'
require 'monkeypatch/array'
require 'monkeypatch/TestCase'
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
	blk = nil
	c1 = nil
	test = contract.on {
		on_method(:test){
			c1 = clause.on{
				pre(blk = "proc {local_variables.find {|v| v.length < 15}.nil? and local_variables.length <= 2;}")
				description("clause must be evaluated in clean context - only unlikely values allowed (proc argument + others must be over 15 chars)")
				name(:clean_namespace)
			}
		}
	}
	context = Context.new(self)

	assert_equal true, c1.check_pre(context.args([1]))

	assert_equal 5,local_variables.length
	assert ! eval(blk).call, "crowed local namespace which return false"
	assert eval_clean(blk).call, "crowed local namespace which return true"
end
def assert_violation (&block)
	assert_exception(nil,ContractViolated,&block)
end
def test_simple
	contract = Contract.new
	
	#I am refactoring Contract to use not duplicate methods into 'pre_' and 'post_' variations.

	#this trickest part of this was avoiding namespace collisions calling eval.
	c2 = c1 = nil
	blk = nil
	m1 = nil
	sqrt = contract
	sqrt.on{
		m1 = on_method(:sqrt) {
			c1 = clause.on{
				pre "proc {|val| val >= 0}"
				description("argument must be non negative")
				name :non_negative
			}
			c2 = clause.on{
				post(blk = "proc {|val| (returned*returned - val).abs < 0.00001}")
				description("work backwards: returned*returned ==(very close) val")
				name(:very_close)
			}
		}
		
	}

	c = sqrt.method_clause(:sqrt)
	assert c
	assert m1
	assert_equal c,m1


	context = Context.new(Sqrt.new)
	sq = sqrt
	assert_equal true, c1.check_pre(context.args [1])
	context.returned 1
	assert_equal true, c2.check_post(context.args [1])

	assert_violation{c1.check_pre(context.args [-1])}

	assert_equal 1,context.returned
	assert_equal true,c2.check_post(context.args [1])
	
	context.instance_eval(blk).call(1)
end
end
