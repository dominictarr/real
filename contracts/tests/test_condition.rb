require 'test/unit'
require 'contracts/condition'
#require 'monkeypatch/array'



class TestCondition < Test::Unit::TestCase
include Test::Unit
#def contract
#	Class.new(Contract)#.check(s = Sqrt.new)
#end

def test_source
	#c = contract	
	#c.pre (:hello).block 
	v = nil
	#value = 'V'
	b = %<proc do |value|
	puts "EVAL : \#{value}"
	v = value end>
	b_block = 	(eval b)
	puts b_block.call(123123)

	assert v = 'hello'

	b = %<proc do length*10; end>

#	x = [:a,:b,:c]
#	puts "LENGTH!: #{x.instance_eval(b).call}"

end

def test_z_array_length_inc_hash
#simulation of pre and post conditions for Array.<<
	pre = Condition.new.on_method(:'<<').
		block(%<proc do |value| @length = @object.length; true; end >).
		name(:length_inc).
		description("saves length to check after")

	post = Condition.new.on_method(:'<<').
		block(%<proc do |returned,value| 1 + @length == @object.length end >).
		name(:length_inc).
		description("length not correct")

	context = Context.new([:a,:b])

	pre.object(context)
	assert pre.call(:c)
	assert_equal 2,context.object.length
	puts context.object.inspect
	r = context.object << :c
	puts "#{context.object.inspect}.#{context.object.object_id}"
	
	post.object(context)
	assert post.call(r,:c)
	puts context.object.inspect
	assert_equal 3, context.object.length

puts "#{context.object.inspect}.#{context.object.object_id}"
end

def test_condition_block_error_message
	pre = Condition.new.on_method(:'<<').
		block(%<proc do |value| @length = @object.length; true; THIS IS AN INTENTSIONAL SYNTAX ERROR TO TEST ERROR MESSAGES >).
		name(:length_inc).
		description("saves length to check after")

	context = Context.new([:a,:b])

	pre.object(context)
	begin
	pre.call(:c)
	rescue => e
		puts e.message
	end
end
def test_eval
	c = Context.new([])
	c.returned(:X)
	assert_equal :X,c.instance_eval("returned")
	assert_equal :X,c.instance_eval("proc do returned end").call
	assert_equal :X,c.instance_eval("proc {returned}").call
	assert_equal :X,c.instance_eval("proc do |val| returned end").call(0)
	assert_equal :X,c.instance_eval("proc {|val| returned}").call(0)
end


end


