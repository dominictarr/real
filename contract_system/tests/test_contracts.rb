require 'test/unit'
require 'contracts'
require 'contracts/array_contract'

class TestContracts < Test::Unit::TestCase
include Test::Unit

def test_couple
	a = couple(ArrayContract).new
	assert a.is_a? Array
	a << :a
	a << :b
	assert_equal 2,a.length
	assert a.__check_wrapped__
end

def test_contract
	c = contract(:NamedContract) {}
	assert_equal c,NamedContract
end

end
