require 'test/unit'
require 'contract_system/contract'
require 'contract_system/contractor'
require 'contract_system/clause'
require 'contracts/array_contract'
require 'monkeypatch/module'
require 'monkeypatch/TestCase'

class TestContractor < Test::Unit::TestCase
include Test::Unit


def test_new
	puts "test_new"	
	#create a new class	
	c = Contractor.new.classes(String)
	assert_equal "", v = c.new
	assert_equal [],c.contracts
end

def test_contract
	puts "test_contract"	
	c = Contractor.new.classes(Array).contracts(ArrayContract)
	a = c.new
	assert_equal a,[]
	assert_equal [ArrayContract],c.contracts
	assert_equal ArrayContract,c.contracts.first
	
	#is c actually wrapped?
	assert a.__check_wrapped__
	assert_equal Array,a.class
	assert [ArrayContract], a.__contracts__
	#right now, we only support a single contract at once. 
	#i'll leave multiple contracts for the next version.
end

class StringInit
	def initialize (string)
	end
	def number(int)
		puts int
	end
end

def test_new_contract
	hi_contract = Contract.new.on {
		name :HelloContract
		on_method(:initialize) {
			clause(:string_arg) {
				pre "proc do |arg| arg.is_a? String end"
					description "initialize(arg) -> arg must be string"
			}
		}
		on_method(:number) {
			clause(:string_arg) {
				pre "proc do |arg| arg.is_a? String end"
					description "initialize(arg) -> arg must be string"
			}
		}
	}
	#test a contract for initialize.
	c = Contractor.new.contracts(hi_contract).classes(StringInit)

	c1 = c.new("hello")
	assert_exception(ContractViolated) {c.new(-1)}
	c.new("")
	assert_exception(ContractViolated) {c.new(nil)}

	c1.number("-1")
	assert_exception(ContractViolated) {c1.number(-1)}
end


end

