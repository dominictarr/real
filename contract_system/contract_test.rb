require 'contract_system/contract'
require 'contract_system/contractor'
require 'contract_system/clause'


#ah, all I have to do, is add a method test(){} to Contract.

class ContractTest
quick_attr :contract,:args,:block, :passes,:test_contractees
def initialize(contract)
	@contract = contract
	test_contractees(Hash.new)
end


def test(*init_args,&test_block)
	args(init_args)
	block(test_block)
	puts "args: #{args}"
	puts "block: #{block}"
#	testing = Contractor.new(@contract).new(*args)
#	instance_eval(&block(
	self
end

def run_test (klass)
	begin
	puts args
	if klass.is_a? Class then
		k = Contractor.new.contracts(@contract).classes(klass).new(*args)
	else
		k = @contract.check(klass)
	end
		k.instance_eval &block
	rescue ContractViolated => v
			raise "test generated ContractViolated on pre condition! #{v.message}" if v.stage == :pre
			puts v
			puts v.message
		return false
	rescue Exception => v
		puts "exception running test: #{v}"
#		puts "at #{v.backtrace.first }"
		puts v.backtrace
		
		return false
	end
	puts "test passes for  #{klass}"
	(test_contractees[contract] ||=[]) << klass
	return true
end

# {|v|
#checks that method called in in the contract.
#	v.method
	#check that preconditions for subcontractees are observed.
	#can't break preconditions - else it's not a valid test.
	#ContractTest tries every class on a test and sees what passes,
	#then builds up a list hash of all classes which pass.
	
#hmm, not every behaviour is possible to check every time.
#for example, f(n)=> number of 1's needed to write every number up to n.
#there isn't an easy way to check it, except using a few examples.

end

