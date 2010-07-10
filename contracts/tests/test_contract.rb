require 'test/unit'
require 'contracts/contract'

class  ImpossibleContract < Contract

	#include Contract

end

class TestContract < Test::Unit::TestCase
include Test::Unit

def test_empty
	permissive = Contract.check("")
	permissive.to_a
	permissive.to_s
end

def test_impossible
	puts ImpossibleContract.methods.include? "pre"
	impossible = ImpossibleContract.check("X")
	begin 
		impossible.to_a
		fail "expected fail as precondition is violated"
#	rescue Exception => v#ContractViolated => v
#		assert v.pre?
#		assert !v.post?
#		assert_equal 'to_a',v.on_method
	rescue
	end
end
end
