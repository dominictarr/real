require 'monkeypatch/module'
require 'monkeypatch/pp_s'


require 'pp'
#require 'awesome'
class Context
	include PP::ObjectMixin
	quick_attr :object,:returned

	def returned (*r)
		if r.empty?
			return @returned
		else
			@returned = r[0]
		end
	end
	def initialize (obj)
		@object = obj
		#@pre_conditions = pre
		#@post_conditions = post
	end
end

class Condition
	include PP::ObjectMixin
	quick_attr :on_method,:stage,:block,:description,:name, :object
	def pre?
		@stage == :pre
	end
	def post?
		@stage == :post
	end
	def indent(string)#move to a print helper mixin?
		string.split("\n").map{|line| "\t#{line}"}.join("\n")
	end
	#
	#all that instance_eval does is set the value of 
	def make_block(context_1239875823,block_1239875823)
		context_1239875823.instance_eval(block_1239875823)
	end
	def call (*args,&block)
		b = @block
		#pp @object
		begin
			returned = nil
			b = make_block(@object,@block) if @block.is_a? String
		rescue SyntaxError => e
			#b = indent(@block)
			raise "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
error evaluating Condition block:\n\n#{indent(@block)}\n\n Error:\n #{indent(e.message)}\nContext:\n#{indent(pp_s(@object))}\n
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
\n\n"
		end
		begin
			r = b.call(*args,&block)
		rescue Exception => e
			raise "had difficulty executing: vvv\n#{@block.to_s}\n^^^\nin context of \nvvv\n#{@object.inspect}\n^^^\nargs:\n#{indent(pp_s(args))}\nError:\n#{e}"
			#save the stack trace from where the clause is created...
			#then you can give the right line.
		end
		passed = r ? "passed" : "FAILED"
		#puts "#{stage}_#{on_method} #{passed} #{name} for #{@object.object.inspect}"
		r
	end
	def to_s
		"#{stage}_#{on_method} \'#{name}\': #{description} "
	end
end

