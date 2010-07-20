require 'monkeypatch/pp_s'
require 'monkeypatch/module'
require 'helpers/string_helper'

class ExampleFailed < StandardError #rewrite this to give better error messages.
	include StringHelper
	quick_attr :contract, :example,:method,:clause,:stage,:error
	def message
		target = example.contractual ? "pass" : "fail"
		cn = contract ? contract.name : "nil"
		args = example ? "(#{example.args})" : ""
		m = ""
		m << "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
example #{example.name} failed to #{target}\n"
#  example:\n #{indent(example,"    ")}"

		if example.contractual then #failed to pass
			m << "clause failed:\n#{clause}
#{error.class}:
    #{error.message}\n"
		else #failed to fail.
			m << "#{example}"
			m << "#{clause}"
		end
		m
	end
	def initialize
		@message = "hello"
	end
end
