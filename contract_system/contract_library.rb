
require 'monkeypatch/module'

class ContractLibrary 
	quick_array :classes,:contracts
	
	def update
		contracts.each{|e|
			classes.each{|k|
				z = e.run_tests(k) #redirect the stdout from here and don't display it... too messy.
				puts "test #{e.name} on #{k.name} -> #{z}"
			}
		}
		puts "================="
		contracts.each{|e|
			puts "#{e.name} => #{pp_s e.contractees}"
		}
	end
	def couple(contract)
		raise "contract #{contract.name} has no contractees" if contract.contractees.empty?
		Contractor.new.contracts(contract).classes(*contract.contractees)
	end
	
	def respect?(klass,contract)
		contract.run_tests((klass.is_a? Class) ? klass : klass.class)
		return contract.contractees.include? klass
	end

end
