require 'monkeypatch/module'
require 'monkeypatch/array'

require 'contracts/context'
class Example
	quick_attr :pre,:post,:returned,:args,:raises,:name,:contractual
	
	def on (&block)
		instance_eval &block
		self
	end
	def check
		raise "Example.check not implemented yet"
	end
end

class Clause
	quick_attr :name,:description,:pre,:post,:exp
	def initialize 
		@calls = 0
	end
	def calls; @calls; end
	def on (&block)
		instance_eval &block
		self
	end
	def indent(string)#move to a print helper mixin?
		string.split("\n").map{|line| "\t#{line}"}.join("\n")
	end
	def make_block(context_1239875823,block_1239875823)
		context_1239875823.instance_eval(block_1239875823)
	end
	def example(bool = nil,&block)
		e = Example.new
		if block then
			e.on(&block) 
			e.check
		self #if there is a block, return self (Clause) so you can chain examples
		else
		e
		end
	end

	def check (context,test,*args,&block)
		#pp @object
		@calls += 1
		raise "expected ruby code to run!" if test.nil?
		begin
			returned = nil
			b = make_block(context,test) if test.is_a? String
			r = b.call(*args,&block)
		rescue SyntaxError => e
			#b = indent(@block)
			raise "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
error evaluating Condition block:\n\n#{indent(test)}\n\n Error:\n #{indent(e.message)}\nContext:\n#{indent(pp_s(context))}\n
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
\n\n"
		rescue Exception => e
			raise "had difficulty executing: vvv\n#{test.to_s}\n^^^\nin context of \nvvv\n#{context.inspect}\n^^^\nargs:\n#{indent(pp_s(args))}\nError:\n#{e}"
			#save the stack trace from where the clause is created...
			#then you can give the right line.
		end

		r
	end
	def check_pre (context,*args,&block)
		return check(context,@pre,*args,&block) if @pre
		true
	end
	def check_post (context,*args,&block)
		return check(context,@post,*args,&block) if @post
		true
	end
	def check_exp (context,*args,&block)
		return check(context,@exp,*args,&block) if @exp
		true
	end
end
