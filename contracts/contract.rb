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
quick_array :contracts
  
	def initialize(object,contract)
		@object = object
		@contract = contract
		contracts(contract)
	end
	def is_wrapped?
		true
	end

	def method_missing(m_name, *args, &block)
#		puts "\t#{m_name}"
		h = Context.new(@object)
		h.args(args)
		h.block(block)

		to_call = proc {@object.method(m_name).call(*args, &block)}
	
		@contract.check_contract(h,m_name,to_call)
	end
end

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

class Contract
	quick_attr :name,:line
	def check (object)
		puts "wrap #{object.class} in #{self.name}"
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
		line caller.first
		run_examples
		self
	end
	def get_method_clauses_for(*syms)
		c = []
		syms.each{|s|
			c << @method_clauses[s]
		}
		c.uniq!
		raise "#{syms.inspect} refur to multiple MethodClauses:#{c.inspect}" if c.length > 1
		c[0] ||  MethodClauses.new
	end
	def on_method(*syms,&block)
		mc = get_method_clauses_for(*syms)
		if block then
			mc.on(&block) 
			mc.line caller.first
		end
		syms.each{|sym|
			@method_clauses[sym] = mc
		}
		mc
	end
	def run_examples
		@method_clauses.each{|name,m|
				begin
					m.run_examples
				rescue ExampleFailed => f
					f.method name
					raise f
				end
		}
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
