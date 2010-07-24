	
require 'contracts' if __FILE__ == $0 

#require 'contracts'

#require 'contracts/contract'

#SymbolContract =  Contract.new.on{

contract(:SymbolContract) {
#===, 
#to_s,
#to_sym,
#inspect
#dclone, id2name, inspect, to_i, to_int, to_proc,   to_yaml

#this is an unusual case, because you can't initialize it you have to make something from an instance
#which means that the contract applies to individual objects, rather than a class.

#maybe this is an acceptable special case.


	on_method(:===).clause {
		description "object identical"
		post "proc do |other| other.object_id == object.object_id end"
	 }
	on_method(:to_sym).clause {
		description "returns self"
		post "proc do returned.object_id == object.object_id end"
	 }
	on_method(:to_s).clause {
		description "returns string which to_sym === self"
		post "proc do returned.to_sym === object end"
	}
	test {
		pp to_s
		pp to_sym
		pp self === self
		pp self === self.to_s.to_sym
	}
}

if __FILE__ == $0 then
	require 'contracts'
	SymbolContract.run_tests(:hello)
	SymbolContract.run_tests(:'hello::bye')
	SymbolContract.run_tests(:<<)
	
	puts SymbolContract.contractees.inspect
end
