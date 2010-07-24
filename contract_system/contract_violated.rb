require 'monkeypatch/pp_s'
require 'monkeypatch/module'
require 'helpers/string_helper'

class ContractViolated < StandardError #rewrite this to give better error messages.
	include StringHelper
	quick_attr :stage,:context,:on_method,:clause
	def pre?
		@stage == :pre
	end
	def post?
		@stage == :post
	end
	def message
		"failed to meet #{stage} clause: \n#{indent(clause.to_s)}\ncontext was:\n#{indent(context.to_s)}"
	end
end

