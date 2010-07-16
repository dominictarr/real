require 'yaml'
require 'monkeypatch/array'

module Test
module Unit
class TestCase

	def assert_same_set (s1,s2)
		assert s1.same_set?(s2), "expected #{s1.inspect}.same_set? #{s2.inspect}"
	end

	def assert_sub_set (s1,s2)
                assert s1.sub_set?(s2), "expected #{s1.inspect}.sub_set? #{s2.inspect}"
        end

        def assert_equal_yaml (s1,s2, m ="")
		assert_equal s1.to_yaml, s2.to_yaml, m
        end

	def assert_exception (message=nil,*exceptions,&block)
			exceptions = exceptions.empty? ? [Exception] : exceptions 
			message = message || "expected block to throw expection: #{exceptions.join (",")}"

		pass = true
		begin
			block.call
			pass = false
		rescue Exception => e
			exp = exceptions.find{|x| e.is_a? x}
			raise "expected exception one of: #{exceptions.inspect}, but got: #{e}\n#{e.backtrace}" if (exp.nil?)
		end

		assert pass, message
	end
end;end;end
