
require 'contracts' if __FILE__ == $0 

contract(:StringContract) {

#     %, *, +, <<, <=>, ==, =~, [], []=, _expand_ch,
#     _fast_gettext_old_format_m, _regex_quote, block_scanf, bytes,
#     bytesize, capitalize, capitalize!, casecmp, center, chars, chomp,
#     chomp!, chop, chop!, concat, count, crypt, delete, delete!,
#     downcase, downcase!, dump, each, each_byte, each_char, each_line,
#     empty?, end_regexp, end_with?, eql?, expand_ch_hash, ext, gsub,
#     gsub!, has_exact_prefix?, hash, hex, include?, indent_by, index,
#     initialize_copy, insert, inspect, intern, is_binary_data?,
#     is_complex_yaml?, iseuc, issjis, isutf8, jcount, jlength, jsize,
#     kconv, length, lines, ljust, lstrip, lstrip!, match, matches,
#     mbchar?, next, next!, oct, original_succ, original_succ!,
#    partition, pathmap, pathmap_explode, pathmap_partial,
#    pathmap_replace, rdoc_to_markdown, replace, reverse, reverse!,
#     rindex, rjust, rpartition, rstrip, rstrip!, scan, scanf,
#     shellescape, shellsplit, size, slice, slice!, split, squeeze,
#     squeeze!, start_with?, strip, strip!, sub, sub!, succ, succ!, sum,
#     swapcase, swapcase!, to_f, to_i, to_reek_source, to_s, to_str,
#     to_sym, to_xs, to_yaml, toeuc, tojis, tosjis, toutf16, toutf8, tr,
#     tr!, tr_s, tr_s!, underscore, unpack, upcase, upcase!, upto,
#     without_pretty_indentation

	on_method(:initialize).clause {
		post "proc do object.is_a? String end"
	}
	#okay. we're just wrapping the string in a contract for now...
	test{
		self << "hello"
	}
}

if __FILE__ == $0 then
	StringContract.run_tests(String)
end
