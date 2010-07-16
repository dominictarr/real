
require 'test/unit'
require 'contracts/contract'
require 'contracts/clause'
require 'monkeypatch/array'
require 'monkeypatch/TestCase'
require 'examples/sqrt'

class TestClause < Test::Unit::TestCase
include Test::Unit

class Hi
	quick_attr :age,:name

	def hello; "Hi"; end

	def tantrum
		raise "here is an exception!"
	end
end
def assert_violation (&block)
	assert_exception(nil,ContractViolated,&block)
end

def test_simple
	c3 = c2 = c1 = nil
	simple1 = Contract.new.on{
		on_method(:hello){
			c1 = clause.name(:is_string).post("proc do returned.is_a? String end")
		}
		on_method(:age,:name){ #this will fail.
			c2 = clause.name(:is_string2).pre("proc do args.length == 1 and args[0].is_a? String end")
				#post("proc do returned.is_a? String end").
				
		}
		on_method(:tantrum){
			c3 = clause.name(:allows_runtime_error).exp("proc do exception.is_a? RuntimeError end")
		}
	}

	assert_equal  MethodClauses, simple1.method_clause(:hello).class
	assert_equal  c1, simple1.method_clause(:hello).clauses[0]
	assert_equal  c2, simple1.method_clause(:age).clauses[0]
	assert_equal  c2, simple1.method_clause(:name).clauses[0]
	assert_equal  c3, simple1.method_clause(:tantrum).clauses[0]

	assert c2.pre
	hi = Hi.new
	context = Context.new(hi)
	context.returned("string")
	assert c1.check_post(context), "expected success"
	context.returned(1)
	assert_violation {c1.check_post(context)}
	
	assert c2.check_pre(context.args(["hi"])), "expected success"
	assert_violation {c2.check_pre(context.args([6]))}

	context.exception(RuntimeError.new)
	assert c3.check_exp(context), "expected success"
	context.exception(SyntaxError.new)
	assert_violation {c3.check_exp(context)}
end

def test_example
	c3 = c2 = c1 = nil
	e1 = e2 = nil
	simple1 = Contract.new.on{
		on_method(:hello){
			c1 = clause{
				name(:is_string)
				post("proc do returned.is_a? String end")
				e1 = example(true) {returned "hello"}
				e2 = example(false) {returned 27}
	}}}

	assert_equal [e1,e2],c1.examples
	assert c1.run_example(e1)
	assert c1.run_example(e2)
	
	e1.contractual  false
	e2.contractual  true
	assert_exception{ c1.run_example(e1)} 
	assert_exception{c1.run_example(e2)}

	simple1.on{
		on_method(:tantrum){
			c3 = clause{
			name(:allows_runtime_error)
			exp("proc do exception.is_a? RuntimeError end")
			
			e1 = example(true){raises RuntimeError.new}
			e2 = example(false){raises SyntaxError.new}
	}}}

	assert c3.run_example(e1)
	assert c3.run_example(e2)

	simple1.on{
		on_method(:age,:name){ #this will fail.
			c2 = clause{
			name(:quick_attr_string)
			pre("proc do args.empty? or (args.length == 1 and args[0].is_a? String) end")
			post("proc do (args.empty? ? returned.is_a?(String) : (returned == object)) end")
			h = Hi.new
			example(true){pre h; post h; args ["hi"];returned h}
			example(true){pre h; post h; args []; returned "hi"}
			example(false){pre h; args ["hi"]; returned "hi"}
			example(false){pre h;args []; post h; returned h}
	}}}
	c2.examples.each{|e|
		assert c2.run_example(e)
	}
end

end