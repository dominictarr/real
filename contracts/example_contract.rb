
require 'contracts' if __FILE__ == $0 
require 'contracts/context_contract'

contract(:ExampleContract){
	on_method(:pre,:post,:returned,:args,:raises,:name,:contractual,:block,:line){
		add_clauses(ContextContract.on_method(:object).clause(:quick_attr_set))
	}
	test {
		pre
		post
		returned 
		args
		raises
		contractual
		block
		line
		
		pre "pre"
		post "post"
		returned :x
		args []
		raises Exception.new
		contractual true
		block {}
		line "hello"
		x = nil
		
		
		#here we are using an explicit test rather than a contract.
		#sometimes it is essential to use a test rather than a contract.

		#some things are easy it check every case
		#	- whether a list is sorted
		#but some things are not possible to check unless you solve the problem.
		
		#  - list many primes < N
		#  - list ways two primes can add to a given number
		# these tasks return a subset with a specific property, so you have to check that it hasn't left anything out.
		#it's much easier to just chuck in a few examples.
		on {x = self.object_id; } 
		raise	"block was not called" unless x
		raise	"block was not called in correct context" unless x == self.object_id

		e = self.class.new
		e.on {x = self.object_id} 
		
		raise	"block was not called" unless x
		raise	"block was not called in correct context" unless x == e.object_id
	}
}


if __FILE__ == $0 then
	require 'contract_system/clause'
	ExampleContract.run_tests(Example)
	
#	puts SymbolContract.contractees.inspect
end


