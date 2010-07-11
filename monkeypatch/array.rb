class Array
def sub_set?(ary)
	ary.each {|it| if !(include? it) then return false; end}
		return true;
end

def same_set?(ary)
		self.sub_set?(ary) && ary.sub_set?(self)
end

def tail
	t = self[1..self.length]
	if t.empty? then nil
	else t end
end

def cartesian_1 (o)
	ret = []
	if o.nil? || o.length == 0 then
		return self 
	end
	each{|a|
		o.each{|b|
#			puts "cart-1 #{a}-#{b.inspect}"
			ret << [a,b]
			}
	}
	ret
end

def cartesian_0
	collect {|it| [it]}
end

def self.cartesian (*list)
	return list.first.cartesian(*list.tail)
end

def cartesian (*list)
	if self.length == 0 then
		raise "cartesian called on empty list - must have contents"
	end
#	puts "CART" + list.inspect
	
	#~ if list.nil? || list.length == 0 then
		#~ self
	#~ els

#	puts list.inspect
	if list.empty? then
		return cartesian_0
	elsif list.first.nil? then
		return cartesian_0
	elsif list.length == 1 then
##		puts list.inspect
		return cartesian_1(list.first)
	else
		ret = []
		rest = list.first.cartesian(*list.tail)
		each{|a|
			rest.each{|b|
#			puts "#{a}-#{b.inspect}"
			ret << [a] + b
			}
		}
	return ret
	end
end

end