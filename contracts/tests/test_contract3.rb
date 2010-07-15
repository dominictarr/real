require 'test/unit'
require 'contracts/contract'
require 'monkeypatch/array'
require 'monkeypatch/TestCase'
require 'examples/sqrt'

class TestContract3 < Test::Unit::TestCase
include Test::Unit

class Hi
	quick_attr :age,:name

	def hello; "Hi"; end

	def tantrum
		raise "here is an exception!"
	end
end

def test_simple
	c3 = c2 = c1 = nil
	simple1 = Contract2.new.on{
		on_method(:hello){
			c1 = clause.name(:is_string).post("proc do returned.is_a? String end")
		}
		on_method(:age,:name){ #this will fail.
			c2 = clause.name(:is_string2).pre("proc do |*args| args.length == 1 and args[0].is_a? String end")
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
	assert !c1.check_post(context), "expected fail"

	assert c2.check_pre(context,"hi"), "expected success"
	assert !c2.check_pre(context,6), "expected fail"

	context.exception(RuntimeError.new)
	assert c3.check_exp(context), "expected success"
	context.exception(SyntaxError.new)
	assert !c3.check_exp(context), "expected fail"
end

def test_more
	c3 = c2 = c1 = nil
	simple2 = Contract2.new.on{
		on_method(:hello){
			c1 = clause.on {
				name :is_string
				post "proc do puts \"RETURNED: \#{returned}\"; returned.is_a? String end" 
		}}
		on_method(:age,:name){ #this will fail.
		  c2 = clause.on {
				name :attr_is_string
				pre "proc do |*args| puts \"ARGS: \#{args.inspect}\";  (args.length == 1 and args[0].is_a? String) or args.empty? end"
				post "proc do returned.is_a? String or returned == object end"
		}} 
		on_method(:tantrum){
			c3 = clause.on{
				name :allows_runtime_error
				exp "proc do puts \"exception!\" exception.is_a? RuntimeError end"
		}}
	}

	hi = simple2.check(Hi.new)
	assert_equal "Hi", hi.hello
	assert_equal hi, hi.age("seven")
	assert_equal "seven", hi.age
	assert_exception (nil,RuntimeError) {hi.tantrum}

	assert_equal 1,c1.calls
	assert_equal 2*2,c2.calls
	assert_equal 1,c3.calls

	#now try breaking contracts.

	assert_exception (nil,ContractViolated) {hi.age(7)}
	assert_exception (nil,ContractViolated) {hi.name(37)}

end
end
