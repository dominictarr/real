require 'monkeypatch/module'
require 'monkeypatch/pp_s'
require 'helpers/string_helper'

require 'pp'
#require 'awesome'
class Context
	include PP::ObjectMixin
	include StringHelper
	quick_attr :object, :exception,:args,:block

	def returned (*r)
		if r.empty?
			return @returned
		else
			@returned = r[0]
			self
		end
	end
	def initialize (obj=nil)
		@object = obj
	end
	def to_s
		s = "Context:\n"
		s << "args: #{args.join(",")}" if args and ! args.empty?
		s << indent(vals_of(:object,:returned,:exception,:block),"  ")
		s << "\n"
	end
end
