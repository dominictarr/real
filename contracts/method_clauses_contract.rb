
require 'contracts' if __FILE__ == $0 
require 'contracts/context_contract'

contract (:MethodClausesContract) {

	raise "NOT PROPERLY IMPLEMETNED YET. WORKING ON CLAUSE'S CONTRACT FIRST"
	on_method(:clauses,:examples,:line){
		add_clauses(ContextContract.on_method(:object).clause(:quick_attr_set))
	}
	#clause create a clause and evaluates a block in that context
	#add_clauses adds a clause to the list
	on_method(:add_clauses){
		clause(:add_clauses){	
			pre %{proc do |*clauses| clauses.find{|c|
					!(respect?(c, :ClauseContract)) #later, check it respects ClauseContract... which isn't written yet.
					}.nil?
				end}
			post %{proc do |*clauses| clauses.find{|c|
						! (object.clauses.include? c)
					}.nil? end}
			description "add clauses"
		}
	}
#	on_method(:run_example){
#		clause(:call_example){
#			pre %{proc do |example| @calls = object.clauses.calls; true end}
#			post %{proc do |example| @calls < example.calls end}
#		}
#	}		

	on_method(:run_examples){
		clause(:call_example){
			pre %{proc do |example| @calls = object.clauses.map{|e| e.calls}; true end}
			post %{proc do |example| t = [@calls,object.clauses.map{|e| e.calls}]
					t = t.transpose;
					pp t
					t.find{|x,y| x < y} end}
			description "check that all examples have been called"
		}	
		example(false){
			m = MethodClauses.new.on{clause {}}
			e = m.example(true){
			}
			pre m
			post m
			args [e]
		}
		example(false){
			m = MethodClauses.new
			m.on{clause {pre "proc do true end"}}
			e = m.example(true){}
			puts m.run_examples
			#pre m
			#m2 = m.dup
			#m2.clauses.first.check_pre(Contract.new)
			#post m2
			#args [e]
		}

	}		


	#run_example run a specific example
	#run_examples run all examples
	#check_method checks contract on this method
	#on evaluates block in own context.
}
