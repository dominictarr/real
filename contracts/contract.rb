require 'monkeypatch/module'
require 'monkeypatch/array'

require 'contracts/condition'

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
	def message 	
		@message
	end
	def initialize (stage,method,condition,*args)
		@stage = stage
		@method = method
		@message = "failed to meet condition: #{condition}\nArguments where: #{args.inspect}"
	end
end
class PostContractViolated < ContractViolated
	def initialize (stage,method,condition,*args)
		super
		@message = "failed to meet condition: #{condition}\nreturned=#{args[0]} args=#{args[1,args.length].join(",")}"
	end
end

  class Contracted
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
	h = Context.new(@object)
	if c = @contract.check_pre(h,m_name,args,&block) then
		raise ContractViolated.new(:pre,m_name,c,*args) 
	end
	rv = @object.method(m_name).call(*args, &block)
	if c = @contract.check_post(h,m_name,rv,args,&block) then
		raise PostContractViolated.new(:post,m_name,c,rv,*args) 
	end
	rv
   end
  end

class Contract
	@pre_conditions = Hash.new
	def self.check (object)
		Contracted.new(object,new)
	end
	def init 
		self.class.instance_variable_set(:@pre_conditions,Hash.new) unless self.class.instance_variable_get(:@pre_conditions)
		self.class.instance_variable_set(:@post_conditions,Hash.new) unless self.class.instance_variable_get(:@post_conditions)
	end
	def self.pre (method, &block)
		#define a method which calls the list of pre conditions for that method.
		@pre_conditions = Hash.new unless @pre_conditions
		cond = Condition.new.on_method(method).block(block).stage(:pre)
		@pre_conditions[method] ? @pre_conditions[method] << cond : @pre_conditions[method] = [cond]
		#define a method which each item in the list
		cond
	end
	def self.post (method, &block)
		@post_conditions = Hash.new unless @post_conditions
		cond = Condition.new.on_method(method).block(block).stage(:post)
		@post_conditions[method] ? @post_conditions[method] << cond : @post_conditions[method] = [cond]
		cond
	end
	def self.pre_conditions(m_sym)
		@pre_conditions = Hash.new unless @pre_conditions
		@pre_conditions[m_sym]
	end
	def self.post_conditions(m_sym)
		@post_conditions = Hash.new unless @post_conditions
		@post_conditions[m_sym]
	end

	def check_pre(context, method,args,&block)
		if p = self.class.pre_conditions(method) then
			p.find {|m|
				m.object(context)
				! m.call(*args)
			}
		else nil end
	end
	def check_post(context, method,returned,args,&block)
		if p = self.class.post_conditions(method) then
			p.find {|m|

				m.object(context)
				! m.call(returned,*args)
			}
		else nil end
	end
end
