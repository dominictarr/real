require 'contracts/contract'

ArrayContract =  Contract.new.on{
	name :ArrayContract
     #&, *, +, -, <<, <=>, ==, [], []=, abbrev, assoc, at, choice, clear,
     #collect, collect!, combination, compact, compact!, concat, count,
     #cycle, dclone, delete, delete_at, delete_if, drop, drop_while,
     #each, each_index, empty?, eql?, fetch, fill, find_index, first,
     #flatten, flatten!, frozen?, hash, include?, index, indexes,
     #indices, initialize_copy, insert, inspect, intersection, join,
     #last, length, map, map!, nitems, pack, permutation, pop,
     #pretty_print, pretty_print_cycle, product, push, rassoc, reject,
     #reject!, replace, reverse, reverse!, reverse_each, rindex, select,
     #shelljoin, shift, shuffle, shuffle!, size, slice, slice!, sort,
     #sort!, take, take_while, to_a, to_ary, to_s, to_yaml, transpose,
     #uniq, uniq!, unshift, values_at, yaml_initialize, zip, |

	on_method(:<<){
		clause{
			name :length_inc
			description "length increases by 1 when <<"
			pre %<proc do |value| @length = @object.length; true; end >
			post %<proc do |value| 1 + @length == @object.length end >
		} 
		clause {
			name :return_self
			description "method returns self"
			post %<proc do returned.object_id  == @object.object_id end >
		}
		clause {
			name :'include?_new'
			description "arg is now in list"
			post %<proc do |value| returned.include?  value end>
		}
		clause {
			name :add_to_end
			description "arg is added to end of list"
			post %<proc do |value| returned.last == value end>
		}
		example (true) {
			x = [:x];
			pre [];post x;args [:x];returned x 
		}
		example (false) {#array stays the same after add.
			x = [:x];
			y = []
			pre y;post y;args [:x];returned y
		}
		example (false) {#new item isn't at end
			x = [:a,:b];
			y = [:a,:x,:b]
			pre x;post y;args [:x];returned y 
		}
		example (true) {#new item at end. 
			x = [:a,:b]
			y = [:a,:b,:x]
			pre x;post y;args [:x];returned y 
		}
		example (false) {#returned isn't self
			x = [:a,:b]
			y = [:a,:b,:x]
			pre x;post y;args [:x];returned [:a,:b,:x]
		}
	}
#way to test with examples of voilations.
	on_method(:delete){
		clause {
			name :length_may_dec
			pre %<proc do |value| @pre_length = @object.length; true; end >
			post %{proc do |value| @pre_length >= @object.length end }
			description("length cannot increase due to delete opperation")} 
		clause {
			name(:deletes_arg)
			post %<proc do |value| !@object.include? value end >
			description "after array.delete (x) x is not in array (deletes all x)" } 
		clause {
			name(:return_arg_or_nil)
			pre %<proc do|value| @do_delete = (object.include? value); true end>
			post %<proc do |value| @do_delete ? returned == value : returned.nil? end >
		}

		example(true) {pre [:x]; args [:x];post [];returned :x}
		example(true) {x = [:x]; pre x; args [:y];post x;returned nil}
		example(false) {x = [:x,:y] #delete says it's deleted but atually it hasn't
			pre x; args [:y];post x;returned :y}
		example(false) {x = [:x,:y] #delete it. but doesn't say so
			pre x; args [:y];post [:x];returned nil}
		example(false) {#length can't get longer
			pre [:x]; args [:y];post [:x,:x];returned nil}
	}
	on_method(:length){
		clause {
			post "proc do returned >= 0 end"
			description "length must be >= 0"
			name :length
		}
		example (false){returned -1}
		example (true){returned 1}
	}
	on_method(:empty?){
		clause {
			post "proc do returned == (object.length == 0) end"
			description "empty? means length == 0"
			name :empty?
		}
		example(true){post []; returned true}
		example(false){post []; returned false}
		example(false){post [:z]; returned true}
	}
}
