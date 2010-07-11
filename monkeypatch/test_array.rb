require 'monkeypatch/array'
require 'test/unit'


class TestArray < Test::Unit::TestCase 
include Test::Unit

def test_same_set?
	#a = [:a,:b,:c,:d]
	assert [:a,:b,:c,:d].same_set? [:a,:c,:d,:b]
end 
def test_sub_set?
	assert [:a,:b,:c,:d].sub_set? [:c,:d]
end

def test_tail
	assert_equal [:b, :c,:d],  [:a,:b,:c,:d].tail 
	assert_equal [[:d]], [[:b, :c],[:d]].tail 
	assert_equal nil,  [[:a,:b,:c,:d]].tail 
end

def test_cartesian
	a = [:a,:b]
	x = [:x,:y]
	m = [:m]

	assert_equal [[:a,:x],[:a,:y],[:b,:x],[:b,:y]], a.cartesian(x)
	assert_equal [[:a,:m],[:b,:m]], a.cartesian(m)
	assert_equal [[:a,:x,:m],[:a,:y,:m],[:b,:x,:m],[:b,:y,:m]], a.cartesian(x,m)
	assert_equal [[:a],[:b]], a.cartesian(nil)
	assert_equal [[:a,:m,:x],[:a,:m,:y],[:b,:m,:x],[:b,:m,:y]], a.cartesian(m,x)
	assert_equal [[:x,:m,:x],[:x,:m,:y],[:y,:m,:x],[:y,:m,:y]], x.cartesian(m,x)
	assert_equal [[nil,:m]],[nil].cartesian(m)
	assert_equal [[:m]],m.cartesian(m.tail)
	
	assert_equal [[:a,:x,:m],[:a,:y,:m],[:b,:x,:m],[:b,:y,:m]], Array.cartesian(a,x,m)
end

def test_from_map_header_style
	#converts a map to an array two arrays, one with headers, on with values.
	map = Hash.new
	map["A"] = "ardvark"
	map["B"] = "bison"
	map["C"] = "cheeta"
	
	assert_equal [["A","B","C"],["ardvark","bison","cheeta"]], [map.keys,map.values]
	
	map2 = Hash.new
	map2["A"] = :ardvark
	map2["B"] = :bison
	map2["C"] = :ardvark
	
	assert_equal [["A","B","C"],[:ardvark,:bison,:ardvark]], [map2.keys,map2.values]
	
end
end
