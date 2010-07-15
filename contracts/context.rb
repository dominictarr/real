require 'monkeypatch/module'
require 'monkeypatch/pp_s'


require 'pp'
#require 'awesome'
class Context
	include PP::ObjectMixin
	quick_attr :object,:returned, :exception,:args,:block

	def returned (*r)
		if r.empty?
			return @returned
		else
			@returned = r[0]
		end
	end
	def initialize (obj)
		@object = obj
		#@pre_conditions = pre
		#@post_conditions = post
	end
end
