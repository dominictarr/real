#load all tests
require 'rubygems'
require 'test/unit'
include Test::Unit

tests = `ls -1 */tests/test*.rb`
#puts tests
tests = tests.split("\n").select{|it|
		puts it 
		it =~ /^.*\/test_.*\.rb$/
		}
#tests.inspect
#tests = tests - ["class_herd/test_rewire2.rb","class_herd/test_interface.rb"]
tests.each{|test|
	puts test
	require test
	}
