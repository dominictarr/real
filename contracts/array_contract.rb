require 'contracts/contract'

class ArrayContract < Contract

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

pre(:'<<').name(:length_inc).
	block(%<proc do |value| @length = @object.length; true; end >).
	description("saves length to check after")
post(:'<<').name(:length_inc).
	block(%<proc do |value| 1 + @length == @object.length end >).
	description("length increases by 1 when <<")
post(:'<<').name(:return_self).
	block(%<proc do |value| returned.object_id  == @object.object_id end >).
	description "method returns self"
post(:'<<').name(:'include?_new').
	block(%<proc do |value| returned.include?  value end >).
	description "arg is now in list"
post(:'<<').name(:add_to_end).
	block(%<proc do |value| returned.last == value end >).
	description "arg is added to end of list"

#way to test with examples of voilations.

pre(:delete).name(:length_may_dec).
	block(%<proc do |value| @pre_length = @object.length; true; end >).
	description("saves length to check after")
post(:delete).name(:length_inc).
	block(%{proc do |value| @pre_length >= @object.length end }).
	description("length cannot increase due to delete opperation")
post(:delete).name(:deletes_arg).
	block(%<proc do |value| !@object.include? value end >).
	description("after array.delete (x) x is not in array (deletes all x)")
post(:delete).name(:return_arg_or_nil).
	block(%<proc do |value| returned == value or returned.nil? end >)

end
