require 'contracts/contract'

class ContextContract < Contract

def self.quick_attr_contract (*args)
	args.each{|sym|
	post(sym).block("proc do |*args,&block| ((args.length > 0 or block) ? (returned == object) : true) end"). #you could set 
		name (:quick_attr_set).
		description(".#{sym}(x) returns self and assigns @#{sym} = x. .attr returns @#{sym}")
	}
end

quick_attr_contract :object, :returned


end

class ConditionContract < Contract
def self.quick_attr_contract (*args)
	args.each{|sym|
	post(sym).block("proc do |*args,&block| ((args.length > 0 or block) ? (returned == object) : true) end"). #you could set 
		name (:quick_attr_set).
		description(".#{sym}(x) returns self and assigns @#{sym} = x. .attr returns @#{sym}")
	}
end

quick_attr_contract :on_method,:stage,:block,:description,:name, :object

pre(:call).block("proc do |*args,&block| !object.block.nil? end").description("block cannot be null when call is invoked").name(:block_not_nil)

end
