require 'test/unit'
require 'contract_system/contract'
require 'monkeypatch/array'
require 'monkeypatch/TestCase'
require 'examples/sqrt'
require 'contract_system/tests/test_clause'
class TestContract3 < Test::Unit::TestCase
include Test::Unit

Hi = TestClause::Hi


def test_more
	c3 = c2 = c1 = nil
	simple2 = Contract.new.on{
		on_method(:hello){
			c1 = clause.on {
				name :is_string
				post "proc do returned.is_a? String end" 
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
				exp "proc do puts \"exception!\"; exception.is_a? RuntimeError end"
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
