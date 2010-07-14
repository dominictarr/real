#weird ruby behaviour eval!

class Local
	attr_accessor :one,:two

	def instance_eval(code)
		eval code
	end
end

def add (a,b)
	puts "#{a} + #{b} = #{a+b}"
end

def context_a(l,code)
	puts "context_a"
	l.instance_eval(code)
end
def context_b(l,code)
	puts "context_b"
	one = 11
	two = 22
	l.instance_eval(code)
end
def context_c(l,code)
	puts "context_c.1"
	begin
	l.instance_eval(code)
	rescue Exception => e
		puts e.message
	end
	puts "context_c.2"
	one = 101
	two = 202
	l.instance_eval(code)
end

	l = Local.new
	l.one = 1
	l.two = 2
 	
	code = "add one,two"

	context_a(l,code)
		
	context_b(l,code)
	context_c(l,code)

#output:
#context_a
#1 + 2 = 3
#context_b
#11 + 22 = 33
#context_c.1
#undefined method `+' for nil:NilClass
#context_c.2
#101 + 202 = 303

