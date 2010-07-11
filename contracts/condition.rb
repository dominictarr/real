require 'monkeypatch/module'
require 'monkeypatch/pp_s'


require 'pp'
#require 'awesome'
class Context
	include PP::ObjectMixin
	def object 
		@object
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
	def call (*args,&block)
		b = @block
		begin
			b = @object.instance_eval(@block) if @block.is_a? String
		rescue SyntaxError => e
			#b = indent(@block)
			raise "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
error evaluating Condition block:\n\n#{indent(@block)}\n\n Error:\n #{indent(e.message)}\nContext:\n#{indent(pp_s(@object))}\n
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
\n\n"
		end
		begin
			b.call(*args,&block)
		rescue Exception => e
			raise "had difficulty executing: vvv\n#{@block}\n^^^\n
in context of \nvvv\n#{@object.inspect}\n^^^\nError:\n
#{e}"
		end

	end
	def to_s
		"#{stage}_#{on_method} \'#{name}\': #{description} "
	end
end

