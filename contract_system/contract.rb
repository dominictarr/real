require 'monkeypatch/module'
require 'monkeypatch/array'

require 'contract_system/context'
require 'contract_system/contractor'
require 'contract_system/clause'
require 'contract_system/method_clauses'
require 'contract_system/contract_violated'
require 'contract_system/contract_test'

class Contract
	quick_attr :name,:line
	quick_array :tests,:contractees

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

#need more useful reporting on which classes respect the contract.

	def test (*args,&block)
		tests << t = ContractTest.new(self).test(*args,&block)
		t
	end
	def run_tests(klass)
		raise "run-tests(MUST BE CLASS)" unless klass.is_a? Class
		if	tests.find{ |t| ! t.run_test(klass)}.nil? then
			pp "TEST RESULT:" 
			pp klass
			contractees << klass unless contractees.include? klass
		end
		
	end
end

