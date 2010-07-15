require 'monkeypatch/module'
require 'monkeypatch/array'

require 'contracts/condition'

class ContractViolated < StandardError
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
      /__.*__/ === method or 'inspect' == method or 'to_s' == method 
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
	#	if c = @contract.check_pre(h,m_name,args,&block) then 
	#		raise ContractViolated.new(:pre,m_name,c,*args) #why is this here? put it in check_pre
	#	end

	@contract.check_pre(h,m_name,args,&block)
	rv = @object.method(m_name).call(*args, &block)
	@contract.check_post(h,m_name,rv,args,&block)

	#	if c = @contract.check_post(h,m_name,rv,args,&block) then
	#		raise PostContractViolated.new(:post,m_name,c,rv,*args) 
	#	end
	rv
   end
  end

class Contract
	def self.check (object)
		Contracted.new(object,new)
	end
	def init 
		self.class.instance_variable_set(:@pre_conditions,Hash.new) unless self.class.instance_variable_get(:@pre_conditions)
		self.class.instance_variable_set(:@post_conditions,Hash.new) unless self.class.instance_variable_get(:@post_conditions)
	end
	def self.clause(stage,method)
	cl = clauses[:"#{stage}_#{method}"] ||=[]
	cl << c = Condition.new.on_method(method).stage(stage)
	c
	end
	def self.pre (method, &block)
		c = clause (:pre,method)
		c.block(block) if block #remove this later.
		c
	end
	def self.post (method, &block)
		c = clause (:post,method)
		c.block(block) if block #remove this later.
		c
	end
	
	#
	# Instead of defining different pre_ and post_ versions of each method...
	# Instead just prefix each symbol with 'pre_' or 'post_' 
	#
	
	def self.clauses
		@clauses = Hash.new unless @clauses
		@clauses
	end
	def self.pre_conditions(m_sym)
		#@pre_conditions = Hash.new unless @pre_conditions
		#@pre_conditions[m_sym]
		clauses[:"pre_#{m_sym}"]
	end
	def self.post_conditions(m_sym)
		clauses[:"post_#{m_sym}"]
	end

	def check_clause(context,method,args,&block)
		if p = self.class.clauses[method] then
			r = p.find {|m| 
				m.object(context)
				! m.call(*args)
			}
		if r then
			stage = (/(\w+?)_/.match(method.to_s)[1]).to_sym
			method = method.to_s.sub(/\w+?_/,"")
			puts stage.inspect
			raise ContractViolated.new(stage,method,r,*args) 
		end
		else nil end
	end

	def check_pre(context, method,args,&block)#except for return value these two methods are duplicated.
		check_clause(context,:"pre_#{method}",args,&block)
	end
	def check_post(context, method,returned,args,&block)
		context.returned(returned)
		check_clause(context,:"post_#{method}",args,&block)
	end
end
