require 'contracts' if __FILE__ == $0 
require 'contracts/context_contract'

contract (:ClauseContract) {
	on_method(:name,:description,:pre,:post,:exp,:examples,:line){
		add_clauses(ContextContract.on_method(:object).clause(:quick_attr_set))
	}
	
	on_method(:initialize).clause(:init){
		post "proc do object.calls == 0 and object.examples == [] end"
	}
	
	#example(bool = nil,&block)
	
	on_method(:example){
		clause{
			post %{
				proc do |bool,&block|
					returned.is_a? Example and #change to respect ExampleContract
					returned.contractual == bool			
				end
			}
		}
		example(true){
			args [true]
			returned Example.new.contractual(true)
		}
		example(false){
			args [true]
			returned Example.new.contractual(false)
		}
	}
	#run_example
	on_method(:run_example){
		clause{
			pre %{
				proc do |example| example.is_a? Example end #change to respect ExampleContract
			}
		}	
		clause(:call_example){
			pre %{proc do |example| @calls = object.calls; true end}
			post %{proc do |example| @calls < object.calls end}
			description "check that all examples have been called"
		}
		example(false){
			pre c = Clause.new
			post c #.on {pre "proc do true end"}
			#calls does not increase
			e = c.example
			args [e]
		}
		example(true){
			pre c = Clause.new
			c2 = c.dup
			c2.pre "proc do true end"
			c2.check_pre(Context.new) #check pre increases call.
			post c2
			#calls does not increase
			e = c.example
			args [e]
		}
	}
	#run_examples
	on_method(:run_examples){
		clause(:call_example){
			pre %{proc do  @calls = object.calls; true end}
			post %{proc do object.examples.empty? or @calls < object.calls end}
			description "check that all examples have been called, unless there arn't any"
		}	
		example(true){
			pre c = Clause.new
			post c
		}
		example(true){
			pre c = Clause.new
			c2 = c.dup
			c2.pre "proc do true end"
			c2.check_pre(Context.new) #check pre increases call.
			post c2
			#calls does not increase
			e = c.example
		}
		example(false){ 
			#fails because calls does not increase, yet there is a example.
			pre c = Clause.new
			c.pre "proc do true end"
			e = c.example
			post c
			#calls does not increase
		}

	}
	
	# on (&block)

[:pre,:post,:exp].each {|stage|
		on_method(stage){
			clause(:correct_syntax){
				pre %{proc do |*code| 
					begin 
						code.empty? or eval(code[0]).is_a? Proc
					rescue SyntaxError => e
						return false
					 end; end} 
					 
				description "#{stage} must be set with string which evals to a block"
			}
			example(true){
				args ["proc do end"]
			}
			example(false){
				args ["proc do INTENTIONAL SYNTAX ERROR"]
			}
		}
		on_method(:"check_#{stage}"){# (context)
			clause ("check_#{stage}"){
				pre "proc do |context| @calls = object.calls; respect?(context.class,:ContextContract) end" #respects ContextContract
				post "proc do |context| 
				(object.#{stage} ? (@calls + 1 == object.calls) : true;) and 
				(returned == true or returned == false) end" #respects ContextContract
			
				exp "proc do |context| [SyntaxError,RuntimeError,ContractViolated].find{|f| context.exception.is_a? f} end" #throws Syntax
				description "increment calls if #{stage} is defined, and return boolean"
			}
			example(true){ #if there is a pre call should increase
				c = Clause.new.name(:clause_in_clause_example1)

				c.method(stage).call "proc do |context| true end"
				c2 = c.dup
				c2.method(:"check_#{stage}").call(x = Context.new) #change to use propper mocks.
			
				pre c
				post c2
				args [x]
				returned true
			}
			example(true){
				c = Clause.new.name(:clause_in_clause_example2)
			
				pre c
				post c
				args [Context.new]
				returned true
			}
			example(false){ #if there is a pre call should increase
				c = Clause.new.name(:clause_in_clause_example3)

				c.method(stage).call "proc do |context| true end"

				pre c
				post c
				args [Context.new]
				returned true
			}
			example(false){
				c = Clause.new.name(:clause_in_clause_example4)

				c.method(stage).call "proc do |context| false end"
				c2 = c.dup
				#c2.method(:"check_#{stage}").call(x = Context.new) #change to use propper mocks.
				#that should throw a 

				pre c
				post c2
				args [Context.new]
			}
		}
	}

	test {
		name;description;pre;post;exp;examples;line;
	
		#if pre/post/exp is not set everthing should return true.
		x = Context.new
		check_pre(x)
		check_post(x)
		check_exp(x)
	
		[:pre,:post,:exp].each {|stage|
			method(stage).call "proc do false end" #must be valid

			begin 
				method("check_#{stage}").call(x)
				raise "test failed: expected a ContractViolated exception"
			rescue ContractViolated => v
			end

			method(stage).call "proc do raise 'CHECK FOR THIS ERROR' end" #must be valid

			begin 
				method("check_#{stage}").call(x)
				raise "test failed: expected an Exception, due to error during runtime."
			rescue Exception => e
				raise "exception should relay message from error" unless e.message.include? 'CHECK FOR THIS ERROR'
				#expects a v
			end
		}
		
		pre "proc do object == \"Hello\" end"
		post "proc do true end"
		exp "proc do true end"
		
		example(true){
				pre "Hello"
		}
		example(false){
				pre "good bye"
		}
		run_examples
		puts "calls #{calls}"
		raise "expected a number of calls during test" unless calls > 1
	}
}

if __FILE__ == $0 then
	require 'contract_system/clause'
	ClauseContract.run_tests(Clause)
	
#	puts SymbolContract.contractees.inspect
end

