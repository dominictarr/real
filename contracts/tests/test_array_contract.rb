require 'test/unit'
require 'contracts'
require 'contracts/array_contract'
require 'contract_system/contract_test'


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

def test_run_tests 
	ArrayContract.run_tests(Array)
	assert_equal [Array],ArrayContract.contractees
end
end
