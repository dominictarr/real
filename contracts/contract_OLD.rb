
class ContractViolated < Exception
	def pre?
		@stage == :pre
	end
	def post?
		@stage == :post
	end
	def on_method
		@method.to_s
	end
	def initialize (stage,method)
		@stage = stage
		@method = method
	end
end

  class Decorator #< BlankSlate
    instance_methods.reject do |method|
      /__.*__/ === method
    end.each do |method|
      undef_method(method)
    end
  
    def initialize(object,contract)
	@object = object
      @contract = contract
#     @contract.send_if_respond_to(:invariant)
    end

    def method_missing(m_name, *args, &block)
	puts "call #{@object.inspect}.#{m_name}"
	raise ContractViolated.new(:pre,m_name) unless @contract.check_pre(@object,m_name,args,&block)
	rv = @object.method(m_name).call(*args, &block)
	raise ContractViolated.new(:post,m_name) unless @contract.check_post(@object,m_name,rv,args,&block)
	#@contract.check_post(method,args)
	rv
   end
  end

class Contract
	@pre_conditions = Hash.new
	def self.check (object)
		Decorator.new(object,new)
	end
	def init 
		self.class.instance_variable_set(:@pre_conditions,Hash.new) unless self.class.instance_variable_get(:@pre_conditions)
		self.class.instance_variable_set(:@post_conditions,Hash.new) unless self.class.instance_variable_get(:@post_conditions)
		#@pre_conditions = Hash.new if @pre_conditions.nil?
	end
	def self.pre (method, &block)
		@pre_conditions = Hash.new unless @pre_conditions
		
		@pre_conditions[method] = block
	end
	def self.post (method, &block)
		@post_conditions = Hash.new unless @post_conditions
		
		@post_conditions[method] = block
	end
	def check_pre(object, method,args,&block)
		init 
		if self.class.instance_variable_get(:@pre_conditions)[method] then
			 self.class.instance_variable_get(:@pre_conditions)[method].call(*args)
		else
			true
		end
	end
	def check_post(object, method,returned,args,&block)
		init 
		if self.class.instance_variable_get(:@post_conditions)[method] then
			 self.class.instance_variable_get(:@post_conditions)[method].call(returned,*args)
		else
			true
		end
	end
end
