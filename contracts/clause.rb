require 'monkeypatch/module'
require 'monkeypatch/array'
require 'contracts/context'
require 'contracts/example_failed'

class Example
	quick_attr :pre,:post,:returned,:args,:raises,:name,:contractual,:block
	
	def on (&block)
		instance_eval &block
		self
	end
	def check
		raise "Example.check not implemented yet"
	end
end

class Clause
	quick_attr :name,:description,:pre,:post,:exp,:examples
	def initialize 
		@calls = 0
		@examples = []
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
		examples  << e = Example.new
		e.contractual bool
		e.on(&block) if block
		e
	end
	def run_examples
		examples.each{|e| run_example(e)}	
	end
	def run_example (e)
		exp = post = pre = true
		c = Context.new(e.pre)
		c.args e.args
		c.block e.block
		v = nil
		begin
			stage = :pre
			pre = check_pre(c)
			if e.raises then
			stage = :exp
				c.exception e.raises
				exp = check_exp(c)
			else
			stage = :post
				c.returned e.returned
				post = check_post(c)
			end
			raise ExampleFailed.new.clause(self).example(e).stage(stage) if !e.contractual
#			raise "expected ContractViolation running example: #{e} on #{self}" 
		rescue ContractViolated => v 
			v.stage stage
			raise ExampleFailed.new.clause(self).example(e).stage(stage).error(v) if e.contractual
		end
		return (pre and exp and post)
	end

	def check (context,test)
		#pp @object
		@calls += 1
		raise "expected ruby code to run!" if test.nil?
		begin
			returned = nil
			b = make_block(context,test) if test.is_a? String
			r = b.call(*context.args,&context.block)
		rescue SyntaxError => e
			#b = indent(@block)
			raise "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
error evaluating Condition block:\n\n#{indent(test)}\n\n Error:\n #{indent(e.message)}\nContext:\n#{indent(pp_s(context))}\n
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
\n\n"
		rescue Exception => e
			raise "had difficulty executing: vvv\n#{test.to_s}\n^^^\nin context of \nvvv\n#{context.inspect}\n^^^\nargs:\n#{indent(pp_s(context.args))}\nError:\n#{e}"
			#save the stack trace from where the clause is created...
			#then you can give the right line.
		end
		raise ContractViolated.new.context(context).clause(self) if !r #replace this with a ExampleFailed exception
		r
	end
	def check_pre (context)
		return check(context,@pre) if @pre
		true
	end
	def check_post (context)
		return check(context,@post) if @post
		true
	end
	def check_exp (context)
		return check(context,@exp) if @exp
		true
	end
end
