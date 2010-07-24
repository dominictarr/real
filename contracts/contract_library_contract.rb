require 'contracts' if __FILE__ == $0 
require 'contracts/array_contract'

contract (:ContractLibraryContract){

	on_method(:classes,:contracts).add_clauses(ContextContract.on_method(:object).clauses.first)
	

	on_method(:couple){
		clause{
			pre "proc do |*contracts| contracts.find{|f| ! f.is_a? Contract}.nil? end" #respects contract contract
			post "proc do |*contracts| returned.is_a? Object and contracts.each{|c| object.respect?(returned.classes.first,c)} end"
			exp "proc do false end"
		}
		example(true) {
			x = Class.new
			def x.respect?(a,b)
				return (a == Array and b == ArrayContract)
			end

			post x
			args [ArrayContract]
			returned Contractor.new.classes(Array).contracts(ArrayContract)
			puts x.respect?(Array,ArrayContract)
		}
		example(true) {
			x = Class.new
			def x.respect?(a,b)
				return false
			end

			args [ArrayContract]
			post x
			returned Contractor.new.classes(Array).contracts(ArrayContract)
		}
	}
	on_method(:respect?){#(klass,contract)
		clause(:respect?){
			pre "proc do |klass,contract| klass.is_a? Class and contract.is_a? Contract end"#respects contract contract
			post "proc do |klass,contract| #run test on every initalization?
				returned == true or returned == false
				end"
			exp "proc do false end"
			description "respect?(klass,contract) is klass adheres/abides by/honours/respects contract. contract.run_tests(klass)"
		}
		example(true) {
			x = Class.new
			def x.respect?(a,b)
				return (a == Array and b == ArrayContract)
			end

			args [Array,ArrayContract]
			post x
			returned true
		}
		example(false) { #there is currently no way to verify this.
			args [ArrayContract,String]
			returned true
		}
	}
	
	test{
		#classes
		#contracts
		self.classes (Array)
		self.contracts (ArrayContract)

		update
		
		a = self.couple(ArrayContract).new
		#puts a.inspect
		raise "didn't find Array" unless  classes.include? Array
		raise "didn't find ArrayContract" unless  contracts.include? ArrayContract
		
		respect?(Array,ArrayContract)
		raise "expected a.is_a? Array,was: #{a.class}" unless a.is_a? Array
		raise "expected wrapped" unless a.__check_wrapped__
		raise "expected a.__contracts__.include? ArrayContract" unless a.__contracts__.include? ArrayContract

		classes << String
		contracts << StringContract
		update

		respect?(String,StringContract)
	
		s = self.couple(StringContract).new

		raise "expected s.is_a? String" unless s.is_a? String
		raise "expected s.__contracts__.include? StringContract" unless s.__contracts__.include? StringContract
	}
}

if __FILE__ == $0 then
	require 'contract_system/contract_library'
		ContractLibraryContract.run_tests(ContractLibrary)
	
#	puts SymbolContract.contractees.inspect
end


