require 'monkeypatch/pp_s'
require 'monkeypatch/module'

class ContractViolated < StandardError #rewrite this to give better error messages.
	quick_attr :stage,:context,:on_method,:clause
	def pre?
		@stage == :pre
	end
	def post?
		@stage == :post
	end
	def message
		"failed to meet #{stage} clause: \n#{pp_s(clause)}\ncontext was:\n #{pp_s(context)}"#\nArguments where: #{context.args.map{|m| m.inspect}.join(",")}"
	end
end

