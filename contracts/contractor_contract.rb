
require 'contracts' if __FILE__ == $0 
require 'contracts/string_contract' 

contract (:ContractorContract){

	on_method(:contracts,:classes) {
			clause (:quick_array) {
				post "proc do |*args| args.empty? ? respect?(returned.class,:ArrayContract) : returned == object end"
			}
			example (true) {
				c = Contractor.new
				post c
				returned [:x]
				args [] 
			}
			example (true) {
				c = Contractor.new
				post c
				returned c
				args [:x]
			}
			example (false) {
				c = Contractor.new
				post c
				returned c
				args []
			}
		
	}
	on_method(:new){
		clause(:new) {
			description "initialize wrapped class"
			post "proc do |*args,&block| returned.__check_wrapped__ and 
					returned.class == object.classes.first and 
					returned.__contracts__ == object.contracts
					end"		
		}
	}
	
 test{
  	#contracts
  	#classes
 
 	self.contracts(StringContract)
 	self.classes(String)

	puts "MAKE NEW StringContract"
 	puts "contracts:#{ self.contracts.inspect}"
 	puts methods.inspect

 	puts "CCCCCCCCCCCC" if self.contracts.first
 	x = self.new()
 	x.__check_wrapped__
 	raise " new didn't wrap it" unless x.__check_wrapped__
 	
	#puts "@@@@@@@@@@@@@@@@@@@@@"
	#puts self.method_missing(:methods).inspect
	#puts "====================="
	#puts self.methods(:methods).inspect
	#puts "@@@@@@@@@@@@@@@@@@@@@"
	
#	was gettting collisions between contracts on Contractor and contracts on Contracted
# the difference is:
# Contractor is used for staging
# Contracted is actually wrapping an instance with a contract checker.

#maybe i need a way to call a method on the wrapper and on the wrapped? 
#one that will make an error if i say i want an outer method and give it an inner method.
 }
}

if __FILE__ == $0 then
	require 'contract_system/contractor'
	ContractorContract.run_tests(Contractor)
	
#	puts SymbolContract.contractees.inspect
end
