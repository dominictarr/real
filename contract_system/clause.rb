require 'monkeypatch/module'
require 'monkeypatch/array'
require 'contract_system/context'
require 'contract_system/example_failed'
require 'helpers/string_helper'

class Example
	quick_attr :pre,:post,:returned,:args,:raises,:name,:contractual,:block,:line
	include StringHelper
	
	def on (&block)
		instance_eval &block
		line caller.first
		self
	end
	def to_s
		s = "Example:#{name}-- should: #{contractual ? "pass" : "fail"}\n  (from #{line})"
		s << indent(vals_of(:pre,:post,:returned,:args,:raises))
		s << "\n"
	end
end

class Clause
	quick_attr :name,:description,:pre,:post,:exp,:examples,:line
	include StringHelper
	def initialize 
		@calls = 0
		@examples = []
	end
	def calls; @calls; end
	def on (&block)
		instance_eval &block
		line caller.first
		self
	end
	def make_block(context_1239875823,block_1239875823)
		context_1239875823.instance_eval(block_1239875823)
	end
	def example(bool = nil,&block)
		examples  << e = Example.new
		e.contractual bool
		e.on(&block) if block
		e.line caller.first
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
			raise "clause cannot check #{test}" unless b.is_a? Proc
			r = b.call(*context.args,&context.block) 

		rescue SyntaxError => e
			raise SyntaxError.new("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  error evaluating Condition block:\n
#{indent(test,"  ")}

  (from #{line})

in context:
#{indent(context.to_s,"    ")}
  SyntaxError:
#{indent(e.message,"    ")}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n")
		rescue Exception => e
			raise "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  tried to call:
#{indent(test.to_s,"    ")}

  (from #{line})
  
  in context: 
#{indent(context.to_s,"    ")}
  #{e.class}:
#{indent(e.message,"    ")}
#{indent(e.backtrace.join("\n"),"    ")}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"

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
	
	def to_s
		s = "Clause:#{name}-- \"#{description}\"\n  (from #{line})\n"
		s << indent(vals_of(:pre,:post,:exp,:examples),"  ")
		s << "\n"
		#s << "\n/>\n"
		s
	end
end
