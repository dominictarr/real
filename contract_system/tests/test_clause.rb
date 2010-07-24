
require 'test/unit'
require 'contract_system/contract'
require 'contract_system/clause'
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
def assert_example_fail (&block)
	assert_exception(nil,ExampleFailed,&block)
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
	c2.run_examples
end

def test_method_example
	m = nil
	simple1 = Contract.new.on{
		m = on_method(:age,:name){ #this will fail.
			c2 = clause{
				name(:quick_attr_string)
				pre("proc do args.empty? or (args.length == 1 and args[0].is_a? String) end")
				post("proc do (args.empty? ? returned.is_a?(String) : (returned == object)) end")
			}
			h = Hi.new
			example(true){pre h; post h; args ["hi"];returned h}
			example(true){pre h; post h; args []; returned "hi"}
			example(false){pre h; args ["hi"]; returned "hi"}
			example(false){pre h;args []; post h; returned h}
	}}
	m.run_examples
	
	m.examples.each{|e| 
		e.contractual !e.contractual
		assert_example_fail {m.run_example(e)}
	}

end

def test_add_clauses
	c2 = m = nil
	simple1 = Contract.new.on{
		m = on_method(:age){ #this will fail.
			c2 = clause{
				name(:quick_attr_string)
				pre("proc do args.empty? or (args.length == 1 and args[0].is_a? String) end")
				post("proc do (args.empty? ? returned.is_a?(String) : (returned == object)) end")
			}
			h = Hi.new
			example(true){pre h; post h; args ["hi"];returned h}
			example(true){pre h; post h; args []; returned "hi"}
			example(false){pre h; args ["hi"]; returned "hi"}
			example(false){pre h;args []; post h; returned h}
		}
		m2 = on_method(:name).add_clauses(c2)
		
	}
	simple1.run_examples
	assert_equal 16,c2.calls
	assert_equal c2, simple1.on_method(:name).named_clause(:quick_attr_string)
	assert_equal c2, simple1.on_method(:name).clause(:quick_attr_string)

	assert_exception{ simple1.on_method(:name).clause{
			name(:quick_attr_string)
		#	pre("proc do args.empty? or (args.length == 1 and not args[0].nil?) end")
		#	post("proc do (args.empty? ? !returned.nil? : (returned == object)) end")
		#	description "quick_attr but cannot be set to nil"
		}
	}
	c3 = nil
	assert_equal c2, simple1.on_method(:name).named_clause(:quick_attr_string)
	simple1.on_method(:name){
		c3 = clause(:quick_attr_string){
			pre("proc do args.empty? or (args.length == 1 and 
				(args[0].is_a? String or 
				args[0].is_a? Numeric)) end")
			post("proc do (args.empty? ? 
			(returned.is_a? String or returned.is_a? Numeric) : 
			(returned == object)) end")
			description "quick_attr but only string or number"
		}
		h = Hi.new
		example(true){pre h; post h; args [27];returned h}
		example(true){pre h; post h; args []; returned 27}
		example(false){pre h; args [27]; returned 27}
		example(false){pre h;args []; post h; returned h}
	}
	assert_equal c3, simple1.on_method(:name).named_clause(:quick_attr_string)
	simple1.on_method(:name).run_examples
end

	def test_error_message
		e1 = c3 = nil
		simple1 = Contract.new.on{
			on_method(:name){
				c3 = clause(:always_fail){
					pre "proc do false end"
				e1 = example(true){}
				}
			}
		}
		assert e1.line
		puts e1.line
		assert e1.line.include? "in `test_error_message'"
	end
end
