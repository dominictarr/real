require 'test/unit'
require 'contracts'
require 'contract_system/contract'

require 'contract_system/contract_test'
require 'contract_system/contractor'
require 'contract_system/clause'
require 'monkeypatch/module'
require 'monkeypatch/TestCase'

require 'contracts/array_contract'
require 'contracts/symbol_contract'

class TestContractTest < Test::Unit::TestCase 
include Test::Unit

class Half 
	def initialize (float)
		@whole = float
	end
	def whole
		return @whole
	end
	def half
		return @whole/2
	end
end
class Half2
	def initialize (float)
		@whole = float
	end
	def half
		return @whole*0.5
	end
	def whole
		return @whole
	end
end
HalfContract = Contract.new.on{
	on_method(:initialize){
		clause(:numeric){
			pre "proc do |val| val.is_a? Numeric end"
			post "proc do |val| val == object.whole end"
		}
	}
	on_method(:half){
		clause(:numeric){
			post "proc do  returned.is_a? Numeric end"
		}
		clause(:half){
			post "proc do (returned * 2) == object.whole end"
		}
	}
	on_method(:whole){
		clause(:numeric){
			post "proc do  returned.is_a? Numeric end"
		}
	}
}

def test_simple
	b = proc {
		puts "wrapped? #{__check_wrapped__}"
		puts "whole:#{whole}"
		puts "half:#{half}"
	}

	t = ContractTest.new(HalfContract).test(2,&b) 

	assert t.run_test(Half)
	t3 = ContractTest.new(HalfContract).test(3,&b) 
	assert t3.run_test(Half2)
	assert !t3.run_test(Half)
	assert !t3.run_test(String)

	assert_equal [Half2],t3.contractees[HalfContract]

#okay, i have basic functionality of this stuff working now. 
#next step is refactor into a usable shape.   
end


def test_with_assert

t = ContractTest.new(HalfContract).test(36){
	raise unless 36 == whole #this could be a post condition on initialize
	raise unless 18 == half #this is not necessary either, because it's defined interms of whole
}

	assert t.run_test(Half)
	assert t.run_test(Half2)

err = ContractTest.new(HalfContract).test("36"){}

	assert_exception(nil,RuntimeError){ err.run_test(Half)}
end

def test_no_initialize 
	assert SymbolContract.run_tests(:hello)
end

end
