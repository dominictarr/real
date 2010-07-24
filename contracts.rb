
require 'contract_system/contract'
require 'contract_system/contractor'
require 'monkeypatch/pp_s'
require 'contract_system/contract_library'


module Kernel
	@@contract_library = ContractLibrary.new
	def contract_library 
		@@contract_library 
	end
	

	def couple(cont)
		contract_library.couple(cont)
	end
	def respect?(klass,cont)
	
		cont = Kernel.const_get(cont) if cont.is_a? Symbol
		contract_library.respect?(klass,cont)
	end
	
	
	def contract(sym,&block)
		begin 
			return const_get(sym)
		rescue NameError
		end
		c = Kernel.const_set(sym,Contract.new.name(sym))
		c.on(&block)
		c
	end


end

require 'contracts/array_contract'
require 'contracts/string_contract'
require 'contracts/symbol_contract'
require 'contracts/contractor_contract'
require 'contracts/context_contract'
require 'contracts/example_contract'
require 'contracts/clause_contract'
require 'contracts/contract_library_contract'

contract_library.classes(Array,String,Symbol,Contractor,Context,Example,Clause,ContractLibrary)
contract_library.contracts(ArrayContract,StringContract,SymbolContract,ContractorContract,ContextContract,ExampleContract,ClauseContract,ContractLibraryContract)
contract_library.update
#find all contracts and run all tests.

