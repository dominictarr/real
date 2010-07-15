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
		@message = "failed to meet #{stage} clause: #{pp_s(condition)}\nArguments where: #{args.map{|m| m.inspect}.join(",")}"
	end
end
class PostContractViolated < ContractViolated
	def initialize (stage,method,condition,*args)
		super
		@message = "failed to meet condition: #{condition}\nreturned=#{args[0]} args=#{args[1,args.length].join(",")}"
	end
end

  class Contracted #delete me
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
  class Contracted2
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
	h.args(args)
	h.block(block)
	#	if c = @contract.check_pre(h,m_name,args,&block) then 
	#		raise ContractViolated.new(:pre,m_name,c,*args) #why is this here? put it in check_pre
	#	end

	to_call = proc {@object.method(m_name).call(*args, &block)}
	#to_call.call
	
	@contract.check_contract(h,m_name,to_call)
   end
  end


class Clause
	quick_attr :name,:description,:pre,:post,:exp
	def initialize 
		@calls = 0
	end
	def calls; @calls; end
	def on (&block)
		instance_eval &block
		self
	end
	def indent(string)#move to a print helper mixin?
		string.split("\n").map{|line| "\t#{line}"}.join("\n")
	end
	def make_block(context_1239875823,block_1239875823)
		context_1239875823.instance_eval(block_1239875823)
	end
	def check (context,test,*args,&block)
		#pp @object
		@calls += 1
		raise "expected ruby code to run!" if test.nil?
		begin
			returned = nil
			b = make_block(context,test) if test.is_a? String
			r = b.call(*args,&block)
		rescue SyntaxError => e
			#b = indent(@block)
			raise "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
error evaluating Condition block:\n\n#{indent(test)}\n\n Error:\n #{indent(e.message)}\nContext:\n#{indent(pp_s(context))}\n
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
\n\n"
		rescue Exception => e
			raise "had difficulty executing: vvv\n#{test.to_s}\n^^^\nin context of \nvvv\n#{context.inspect}\n^^^\nargs:\n#{indent(pp_s(args))}\nError:\n#{e}"
			#save the stack trace from where the clause is created...
			#then you can give the right line.
		end

		r
	end
	def check_pre (context,*args,&block)
		return check(context,@pre,*args,&block) if @pre
		true
	end
	def check_post (context,*args,&block)
		return check(context,@post,*args,&block) if @post
		true
	end
	def check_exp (context,*args,&block)
		return check(context,@exp,*args,&block) if @exp
		true
	end
end

class MethodClauses #a set of clauses which apply to a particular method

	quick_attr :clauses

	def clause
		@clauses << c = Clause.new
		c
	end

	def initialize
		@clauses = []
	end
	def on (&block)
		instance_eval &block
		self
	end
end

class Contract2
	def check (object)
		Contracted2.new(object,self)
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
	end
	def on_method(*syms,&block)
		mc = MethodClauses.new.on(&block)
		syms.each{|sym|
			@method_clauses[sym] = mc
		}
		self
	end

	def check_contract(context,method,to_call)
		m = method_clause(method)
		puts "METHOD_CLAUSE"
		#pp m
		return to_call.call if m.nil?
		l = method_clause(method).clauses
		puts "CLAUSES"
		pp l
		return to_call.call if l.nil?
		l.each {|c|
			print "pre "
			x = c.check_pre(context,*context.args,&context.block)
			raise ContractViolated.new(:pre,method,c,*context.args) if !x
		}
		begin 
			context.returned(to_call.call);
		rescue Exception => e
		context.exception(e)
		l.each {|c|
			print "exp "
			x = c.check_exp(context,*context.args,&context.block)
			raise ContractViolated.new(:exp,method,c,*context.args) if !x
		}
		raise e
		end
		l.each {|c|
			print "post "
			x = c.check_post(context,*context.args,&context.block)
			raise ContractViolated.new(:post,method,c,*context.args) if !x
		}
		puts
		context.returned
	end
end

class Contract
	def check (object)
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
	end
	def on_method(*syms,&block)
		mc = MethodClauses.new.on(&block)
		syms.each{|sym|
			@method_clauses[sym] = mc
		}
		self
	end
	def clause(stage,method)
	cl = clauses[:"#{stage}_#{method}"] ||=[]
	cl << c = Condition.new.on_method(method).stage(stage)
	c
	end
	def pre (method, &block)
		c = clause (:pre,method)
		c.block(block) if block #remove this later.
		c
	end
	def post (method, &block)
		c = clause (:post,method)
		c.block(block) if block #remove this later.
		c
	end
	
	#
	# Instead of defining different pre_ and post_ versions of each method...
	# Instead just prefix each symbol with 'pre_' or 'post_' 
	#

	def clauses
		@clauses
	end
	def pre_conditions(m_sym)
		#@pre_conditions = Hash.new unless @pre_conditions
		#@pre_conditions[m_sym]
		clauses[:"pre_#{m_sym}"]
	end
	def post_conditions(m_sym)
		clauses[:"post_#{m_sym}"]
	end

	def check_clause(context,method,args,&block)
		if p = clauses[method] then
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
