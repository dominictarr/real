require 'contracts'
require 'contract_system/contract'

#def quick_attr_contract (contract,*args)
#	args.each{|sym|
#	contract.on_methods(sym).clause(:quick_attr_set){
#		name ()
#		post "proc do |*args,&block| ((args.length > 0 or block) ? (returned == object) : true) end"
#		description(".#{sym}(x) returns self and assigns @#{sym} = x. .attr returns @#{sym}")
#	}
#end

#ContextContract = Contract.new
contract(:ContextContract){
	on_method(:object, :returned,:args,:block,:exception){
		clause(:quick_attr_set){
			name ()
			post "proc do |*args,&block| ((args.length > 0 or block) ? (returned == object) : true) end"
			description(".attr(x) returns self and assigns @attr = x. .attr returns @attr")
		}
		example(true){
			post c = Context.new
			args []
			returned :x #we're ignoring state here! 
		}
		example(true){
			post c = Context.new
			args [:x]
			returned c #we're ignoring state (and types here) here! 
		}
		example(false){
			post c = Context.new
			args [:x]
			returned :x #we're ignoring state (and types here) here! 
		}
	}
	
	test{
		object
		returned
		args
		block
		exception

		#returned :x
		object :y
		args []
		block {}
		exception Exception.new	
	}
}


if __FILE__ == $0 then
	require 'contract_system/context'
	ContextContract.run_tests(Context)
	
#	puts SymbolContract.contractees.inspect
end


