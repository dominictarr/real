class Condition
	def initialize (stage,method,description,&block)
		@stage - stage
		@method = method
		@description = description
		@block = block
	end
end

class Contract
	@pre_conditions = Hash.new
	@post_conditions = Hash.new

	def self.check(object)
		object
	end

	def self.pre (method, description,&block)
		@pre_conditions[method] << Conditon(:pre,method,description,&block)
	end
end
