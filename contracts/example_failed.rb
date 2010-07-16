require 'monkeypatch/pp_s'
require 'monkeypatch/module'

class ExampleFailed < StandardError #rewrite this to give better error messages.
	quick_attr :contract, :example,:method,:clause,:stage,:error

	def message
		target = example.contractual ? "pass" : "fail"
		cn = contract ? contract.name : "nil"
		args = example ? "(#{example.args})" : ""
		m = ""
		m << "\ncontract #{cn}.#{method} #{args} failed to #{target}\n example:\n #{pp_s(example)}"

		if example and example.contractual then 
			m << " error was:\n\t#{error}\n"
			m << error.message
			error.backtrace.each{|e| m << "\t#{e}\n"}
			m << "..end of error"
		else
			m << " expected error, but nothing"
		end
		
		m
	end
	def initialize
		@message = "hello"
	end
end
