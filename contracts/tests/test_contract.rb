require 'test/unit'
require 'contracts/contract'
require 'monkeypatch/array'
require 'examples/sqrt'

class TestContract < Test::Unit::TestCase
include Test::Unit

#
#an empty contract will permit everything.
#
class ImpossibleContract < Contract
	pre(:to_a).block("proc do false end")
end
class ToArrayContract < Contract
	post(:to_a).block("proc do returned.is_a? Array end").description("returns an array")

 #is_a should instead be abides_by? (ArrayContract)
end

def test_empty
	permissive = Contract.check("")
	permissive.to_a
	permissive.to_s
	#assert permissive.passes?
end

def test_impossible
	#impossible_class =Class.new(Contract)
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
def contract
	Class.new(Contract)#.check(s = Sqrt.new)
end
def sqrt_contract
	sqrt = contract
	sqrt.pre(:sqrt) .block("proc do |val| val >= 0 end").description("argument must be non negative")
	sqrt.post(:sqrt).block("proc do |val|
		(returned*returned - val).abs < 0.00001 end").
	description("work backwards: returned*returned ==(very close) val").name(:very_close)
	sqrt
end
def sqrt_contract2
	sqrt = sqrt_contract
	sqrt.post(:sqrt).block("proc do |val|
		if val > 1 then
			val > returned 
		elsif val == 0  then
			returned == 0
		elsif val < 1 then
			val < returned 
		elsif val == 1 then
			returned == 1
		end
	end").
	description("val > returned > 1 or val < returned < 1 or val == returned == 1 or 0"). #let condition take a block which can build a nice error message?
	name(:range)
	sqrt
end

def test_sqrt
	q = sqrt_contract.check(s = Sqrt.new)

	assert_equal 1, q.sqrt(1)
	assert_equal 2, q.sqrt(4)
	assert_equal 3, q.sqrt(9)
	assert_equal 3.162, (q.sqrt(10) * 1000).round / 1000.0

	assert_equal 0.5, q.sqrt(0.25)

	assert_equal 0, q.sqrt(0)
	begin
		q.sqrt(-1)
		fail "expected  ContractViolation"
	rescue ContractViolated => v
	end

	q = sqrt_contract.check(s = Sqrt.new)
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


def test_post_conditions
	sqrt = sqrt_contract2

	c = sqrt.pre_conditions(:sqrt)
	assert c.length == 1
	assert_equal :sqrt, c[0].on_method
	assert c[0].pre?

	q = sqrt.check(s = Sqrt.new)
	assert_equal 1, q.sqrt(1)
	assert_equal 2, q.sqrt(4)
	assert_equal 3, q.sqrt(9)
	assert_equal 3.162, (q.sqrt(10) * 1000).round / 1000.0
	assert_equal 0, q.sqrt(0)
end

def test_examples

examples = {1=>1,4=>2,16=>4,36=>6,0=>0,36=>6,2=>1.414213562,10=>3.16227766}
equality = proc {|a,b| (a - b).abs < 0.000001}

sqrt = sqrt_contract2
	q = sqrt.check(s = Sqrt.new)
	examples.each {|arg,result| 
		assert equality.call(result, q.sqrt(arg))
	}
#assert_equal s.methods,q.methods

q = sqrt.check(s = Sqrt2.new)
	examples.each {|arg,result|
		assert equality.call(result, q.sqrt(arg))
	}
#assert_equal s.methods,q.methods
end

def test_z_array_length_inc_hash
	c = contract
	pre = c.pre(:'<<').block(%<proc do |value| @length = @object.length; true; end >).name(:length_inc).description("saves length to check after")
	post = c.post(:'<<').block(%<proc do |value| @length + 1 == @object.length end >).name(:length_inc).description("length not correct")
	
	a = c.check([:a,:b])
	a << :c
	assert [:a,:b,:c],a
end

end

