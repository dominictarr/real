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
	quick_attr :clauses

	def clause(&block)
		@clauses << c = Clause.new
		c.on(&block) if block
		c
	end

	def initialize
		@clauses = []
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
		#puts "METHOD_CLAUSE"
		#MOVE ALL THIS CODE INTO MethodClause
		#pp m
		return to_call.call if m.nil?
		l = method_clause(method).clauses
		puts "CLAUSES"
		pp l
		return to_call.call if l.nil?
		l.each {|c|
			print "pre "
			x = c.check_pre(context)
			raise ContractViolated.new(:pre,method,c,*context.args) if !x
		}
		begin 
			context.returned(to_call.call);
		rescue Exception => e
		context.exception(e)
		l.each {|c|
			print "exp "
			x = c.check_exp(context)
			raise ContractViolated.new(:exp,method,c,*context.args) if !x
		}
		raise e
		end
		l.each {|c|
			print "post "
			x = c.check_post(context)
			raise ContractViolated.new(:post,method,c,*context.args) if !x
		}
		puts
		context.returned
	end
end
