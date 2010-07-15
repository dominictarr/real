require 'test/unit'
require 'contracts/contract_tester'
require 'contracts/condition_contract'

class TestContextContract < Test::Unit::TestCase
include Test::Unit

	quick_attr :contract_tester

	def example *args
		assert contract_tester.example(*args)
	end

	def test_simple
		contract_tester ContractTester.new.contract(ContextContract)
		#(:pre,:post,:returned,:args,:on_method,:name,:contractual)
		c = Context.new(nil)
		#contract for object (a quick_attr)
		example c,c,c,[:x],:object,:quick_attr_set,true
		example c,c,:x,[],:object,:quick_attr_set,true

		example c,c,:x,[:x],:object,:quick_attr_set,false

		#contract for returned (a quick_attr)
		example c,c,c,[:x],:returned,:quick_attr_set,true
		example c,c,:x,[],:returned,:quick_attr_set,true

		example c,c,:x,[:x],:returned,:quick_attr_set,false
	end
end

class TestConditionContract < Test::Unit::TestCase
include Test::Unit
	quick_attr :contract_tester

	def example *args
		assert contract_tester.example(*args)
	end


	def test_quick_attr(sym,c)
		example c,c,c,[:x],sym,:quick_attr_set,true
		example c,c,:x,[],sym,:quick_attr_set,true

		example c,c,:x,[:x],sym,:quick_attr_set,false
	end
	def test_quick_attrs
		
		contract_tester ContractTester.new.contract(ConditionContract)
		#(:pre,:post,:returned,:args,:on_method,:name,:contractual)
		c = Condition.new()
		[:on_method,:stage,:block,:description,:name, :object].each{|a|

			test_quick_attr(a,c)
		}
	end

	def test_call
		contract_tester ContractTester.new.contract(ConditionContract)
	
		c = Condition.new()
		c.block ("proc do true; end")
		example c,c,true,[],:call,:block_not_nil,true
		d = Condition.new()
		example d,d,true,[],:call,:block_not_nil,false
		e = Condition.new().block("proc do false; end")
		example d,d,false,[],:call,:block_not_nil,false

		#call is contracted to throw an ContractViolated exception if block returns false.
		#will probably need another category exp_... for that.
	end
end
