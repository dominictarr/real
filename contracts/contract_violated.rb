require 'monkeypatch/pp_s'

class ContractViolated < StandardError #rewrite this to give better error messages.
	def pre?
		@stage == :pre
	end
	def post?
		@stage == :post
	end
	def on_method
		@method.to_s
	end
	def message 	
		@message
	end
	def initialize (stage,method,condition,*args)
		@stage = stage
		@method = method
		@message = "failed to meet #{stage} clause: #{pp_s(condition)}\nArguments where: #{args.map{|m| m.inspect}.join(",")}"
	end
end

