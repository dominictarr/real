require 'monkeypatch/module'
require 'monkeypatch/array'

require 'contracts/context'
require 'contracts/clause'
require 'contracts/contract_violated'

class Contracted
   instance_methods.reject do |method|
	   /__.*__/ === method or 'inspect' == method or 'to_s' == method 
	end.each do |method|
		undef_method(method)
	end
  
	def initialize(object,contract)
		@object = object
		@contract = contract
	end

	def method_missing(m_name, *args, &block)
		h = Context.new(@object)
		h.args(args)
		h.block(block)

		to_call = proc {@object.method(m_name).call(*args, &block)}
	
		@contract.check_contract(h,m_name,to_call)
	end
end

class MethodClauses #a set of clauses which apply to a particular method
	quick_attr :clauses,:examples

	def clause(&block)
		@clauses << c = Clause.new
		c.on(&block) if block
		c
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
			raise "expected #{e} to fail to run on #{self}" if !e.contractual
			
		rescue ContractViolated => v
			raise "example failed: #{e} to run on #{self}" if e.contractual
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

class Contract
	def check (object)
		Contracted.new(object,self)
	end
	def initialize
		@clauses = Hash.new
		@method_clauses = Hash.new
	end
	def method_clause(sym)
		@method_clauses[sym]
	end
	def on (&block)
		instance_eval &block
		self
	end
	def on_method(*syms,&block)
		mc = MethodClauses.new
		mc.on(&block) if block
		syms.each{|sym|
			@method_clauses[sym] = mc
		}
		mc
	end

	def check_contract(context,method,to_call)
		m = method_clause(method)
		begin
			if m then
				m.check_method(context,to_call)
			else
				to_call.call if m.nil?
			end
		rescue ContractViolated => v
			v.on_method method.to_s
			raise v
		end

	end
end
