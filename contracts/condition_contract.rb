require 'contracts/contract'

def quick_attr_contract (contract,*args)
	args.each{|sym|
	contract.post(sym).block("proc do |*args,&block| ((args.length > 0 or block) ? (returned == object) : true) end"). #you could set 
		name (:quick_attr_set).
		description(".#{sym}(x) returns self and assigns @#{sym} = x. .attr returns @#{sym}")
	}
end

ContextContract = Contract.new
quick_attr_contract(ContextContract,:object, :returned)

ConditionContract = Contract.new
quick_attr_contract(ConditionContract,:on_method,:stage,:block,:description,:name, :object)

ConditionContract.pre(:call).block("proc do |*args,&block| !object.block.nil? end").description("block cannot be null when call is invoked").name(:block_not_nil)


