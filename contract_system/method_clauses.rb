require 'monkeypatch/module'
require 'monkeypatch/array'

require 'contract_system/context'
require 'contract_system/contractor'
require 'contract_system/clause'
require 'contract_system/contract_violated'
require 'contract_system/contract_test'

class MethodClauses #a set of clauses which apply to a particular method
	quick_attr :clauses,:examples,:line

	def named_clause(name)
		return nil if name.nil?
		clauses.find{|f|
			f.name == name			
		}
	end
	def clause(name=nil,&block)
		c = (named_clause(name) || Clause.new.name(name))
		@clauses << c unless @clauses.include? c
		if block then
			c.on(&block)
			c.line caller.first
		end
		#throw exception is name is used.
		if c.name then
			sel = @clauses.select {|s|
				s.name == c.name
			}
			if sel.length > 1 then
				@clauses.delete c
				raise "error, more than one clause named #{c.name}:#{pp_s(sel)} for #{self}"
			end
		end
		c
	end
	def add_clauses(*clauses)
		@clauses = @clauses + clauses		
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
	def run_example(e)
		begin
			c = Context.new
			c.args(e.args)
			c.block(e.block)
			c.object(e.pre)
			to_call = proc {|*args| c.object(e.post); raise e.raises if e.raises; e.returned}
			check_method(c,to_call)
			
			raise ExampleFailed.new.example(e) if !e.contractual 
		rescue ContractViolated => v
			raise ExampleFailed.new.example(e).error(v).clause(v.clause) if e.contractual
			#raise "example failed: #{e} to run on #{self}" if e.contractual
		end
	end
	def check_method(context,to_call)
		l = clauses
		return to_call.call if l.nil?
		stage = nil
		begin
			l.each {|c|
				stage = :pre 
				x = c.check_pre(context)
				raise ContractViolated.new(:pre,method,c,*context.args) if !x
			}
			begin 
				context.returned(to_call.call);
			rescue Exception => e
			context.exception(e)
			l.each {|c|
				stage = :exp
				x = c.check_exp(context)
				raise ContractViolated.new(:exp,method,c,*context.args) if !x
			}
			raise e
			end
			l.each {|c|
				stage = :post
				x = c.check_post(context)
				raise ContractViolated.new(:post,method,c,*context.args) if !x
			}
			puts
			context.returned
		rescue ContractViolated => v
			v.stage stage
			raise v
		end
	end
def initialize
		@clauses = []
		@examples = []
	end
	def on (&block)
		instance_eval &block
		self
	end
end

