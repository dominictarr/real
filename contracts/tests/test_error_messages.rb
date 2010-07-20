require 'test/unit'
require 'contracts/contract'
require 'contracts/clause'
require 'monkeypatch/array'
require 'monkeypatch/TestCase'

class TestErrorMessages < Test::Unit::TestCase
include Test::Unit

class Hi
	def hello; "Hi"; end
	def goodbye; "Bye"; end
	def strange; "colourless green ideas sleep furiously"; end
	def incoherent; "sahlafksd"; end
end

#ERROR MESSAGES:
	#~ -true example failed
	#~ -false example failed to fail
	#~ -contract violation
	#~ -pre/post/exp syntax error,
	#~ -pre/post/exp runtime error

def print_error 
	fail = true;
	begin 
		yield
		fail = false;
	rescue Exception => e
		puts e.class
		puts e.message
	end
	assert fail, "expected fail"
end

def test_example_messages
	c_always = nil
	c_never = nil
	errors = Contract.new.on{
		on_method(:hello){
			c_always = clause (:always){
				description "always passes"
				example(false){}#fails to fail
			}
		}
		on_method(:goodbye){
			c_never = clause (:never){
				pre "proc do false end"
				description "always fails" 
				example(true){}#always failed
			}
		}#also method level errors.
		on_method(:strange){
		clause (:syntax){
				pre "proc do false INTENSIONAL SYNTAX ERROR"
				description "doesnt compile"
			}
		}
		on_method(:incoherent){
		clause (:runtime){
				pre "proc do 10 / 0 end"
				description "runtime error"
			}
		}
	}

	h = errors.check(Hi.new)
	puts "####################"
	puts "ContractViolation error"
	puts "####################"
	print_error {h.goodbye}
	#
	puts "####################"
	puts "syntax error in contract clause"
	puts "####################"
	print_error{h.strange}
	puts "####################"
	puts "runtime error in contract clause"
	puts "####################"
	print_error{h.incoherent}
	puts "####################"
	puts "failed to pass in contract clause example"
	puts "####################"

	print_error{c_never.run_examples}
	puts "####################"
	puts "failed to fail in contract clause example"
	puts "####################"
	print_error{c_always.run_examples}
end
end
