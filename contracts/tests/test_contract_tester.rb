require 'test/unit'
require 'contracts/contract'
require 'contracts/contract_tester'


class TestContractTester < Test::Unit::TestCase
include Test::Unit

def test_contract
	contract = Contract.new
	ct = ContractTester.new.contract(contract)
	assert_equal contract,ct.contract

	ct.examples []
	assert_equal [],ct.examples
end

class Ex
	quick_attr :valid
	def is_valid?; @valid; end
	def test; is_valid?; end
end

def example_contract
	contract = Contract.new
	contract.pre(:test).block("proc do puts \"VALID? \#{object.valid}\"; object.is_valid? end").name(:test_valid).description("is_valid? == true")
	contract.post(:test).block("proc do puts \"RETURNED: \#{returned}\"; returned == true end").name(:test_returned).description("returned == true")
	contract.post(:test).block("proc do object.is_valid? == true end").name(:test_still_valid).description("is_valid? == true")
	contract
end

def test_run_example
	contract = example_contract
	ct = ContractTester.new.contract(contract)
		#:pre,:post,:returned,:args,:on_method,:name,:contractual
	valid = Ex.new.valid(true)
	invalid = Ex.new.valid(false)

	assert valid.is_valid?
	assert !invalid.is_valid?

	ct.examples << e1 = ContractTester::Example.new(valid,valid,true,nil,:test,:test_valid,true)
	ct.examples << e2 = ContractTester::Example.new(invalid,invalid,true,nil,:test,:test_valid,false)
#	pp contract.clauses
	assert ct.run_example(e1), "test postive example"
	assert ct.run_example(e2), "test negative example"

	ct.examples << e3 = ContractTester::Example.new(valid,valid,true,nil,:test,:test_returned,true)
	ct.examples << e4 = ContractTester::Example.new(invalid,invalid,false,nil,:test,:test_returned,false)

	assert ct.run_example(e3), "test postive example"
	assert ct.run_example(e4), "test negative example"

	assert ct.run_examples
	#coverage?
	assert ct.example(valid,valid,true,nil,:test,:test_still_valid,true)

end


end
