require 'test/unit'
require 'contracts/contract'

class TestContract < Test::Unit::TestCase
include Test::Unit

#
#an empty contract will permit everything.
#
class ImpossibleContract < Contract
	pre(:to_a){false}
end
class ToArrayContract < Contract
	post(:to_a){|returned| returned.is_a? Array} #is_a should instead be abides_by? (ArrayContract)
end


class SqrtContract < Contract 
	pre(:sqrt) {|val| val >= 0}
	pre(:post) {|returned,val|
		if returned > 1 then
			val > returned 
		elsif returned < 1 then
			val < returned 
		elsif returned == 1 or
			val == 1
		end
	}
end
class SqrtContract2 < Contract 
	pre(:sqrt) {|val| val >= 0}
	pre(:post) {|returned,val|
		return returned*returned == val
	}
end


class Sqrt
	def sqrt (val)
		Math.sqrt(val)
	end
end
def test_empty
	permissive = Contract.check("")
	permissive.to_a
	permissive.to_s
	#assert permissive.passes?
end

def test_impossible
#	impossible_class =Class.new(Contract)
#a contract which always returns false.
#it is forbidden to call to_s under this contract.
	impossible = ImpossibleContract.check("X")
	begin 
		impossible.to_a
		fail "expected fail as precondition is violated"
	rescue ContractViolated => v
		assert v.pre?
		assert !v.post?
		assert_equal 'to_a',v.on_method
	end
end

def test_post
	h = {:X=>:Y}
	to_a_able = ToArrayContract.check(h)
	assert_equal h.to_a, to_a_able.to_a
end

def test_sqrt

	q = SqrtContract.check(s = Sqrt.new)

	assert_equal 1, q.sqrt(1)
	assert_equal 2, q.sqrt(4)
	assert_equal 3, q.sqrt(9)
	assert_equal 3.162, (q.sqrt(10) * 1000).round / 1000.0

	assert_equal 0.5, q.sqrt(0.25)
	begin
		q.sqrt(-1)
		fail "expected  ContractViolation"
	rescue ContractViolated => v
	end

	q = SqrtContract2.check(s = Sqrt.new)
	assert_equal 1, q.sqrt(1)
	assert_equal 2, q.sqrt(4)
	assert_equal 3, q.sqrt(9)
	assert_equal 3.162, (q.sqrt(10) * 1000).round / 1000.0

	assert_equal 0.5, q.sqrt(0.25)
	begin
		q.sqrt(-1)
		fail "expected  ContractViolation"
	rescue ContractViolated => v
	end


end


end

