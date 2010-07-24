require 'contracts' if __FILE__ == $0 

contract(:ContextContract){
	on_method(:object, :returned,:args,:block,:exception){
		clause(:quick_attr_set){
			name ()
			post "proc do |*args,&block| ((args.length > 0 or block) ? (returned == object) : true) end"
			description(".attr(x) returns self and assigns @attr = x. .attr returns @attr")
		}
		example(true){
			post c = "post"
			args []
			returned :x #we're ignoring state here! 
		}
		example(true){
			post c = "post"
			args [:x]
			returned c #we're ignoring state (and types here) here! 
		}
		example(false){
			post c = "post"
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

		returned :x
		object :hello
		args []
		block {}
		exception Exception.new	
	}
}
if __FILE__ == $0 then
	require 'contract_system/context'
	ContextContract.run_tests(Context)
	pp ContextContract.contractees
#	puts SymbolContract.contractees.inspect
end


