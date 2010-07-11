require 'monkeypatch/module'
require 'test/unit'


class TestModule < Test::Unit::TestCase 
include Test::Unit


class Hello
 end
def test_simple
	Hello.quick_attr :one,:two,:three
	h = Hello.new.one("A").two("B").three("C")
	assert_equal "A", h.one
	assert_equal "B", h.two
	assert_equal "C", h.three

	assert_equal -1,h.method(:one).arity
	assert_equal -1,h.method(:two).arity
	assert_equal -1,h.method(:three).arity
end
	

def test_simple2
	Hello.quick_attr :one,:two,:three
	h = Hello.new.one(100).two(200).three(300)
	assert_equal 100, h.one
	assert_equal 200, h.two
	assert_equal 300, h.three

	assert_equal -1,h.method(:one).arity
	assert_equal -1,h.method(:two).arity
	assert_equal -1,h.method(:three).arity
end

def test_nil_or_empty
	Hello.quick_attr :_nil,:_empty,:_false
	h = Hello.new._nil(nil)._empty("")._false(false)
	assert_equal nil, h._nil
	assert_equal "", h._empty
	assert_equal false, h._false

	assert_equal -1,h.method(:_nil).arity
	assert_equal -1,h.method(:_empty).arity
	assert_equal -1,h.method(:_false).arity
end

def test_arrays
	Hello.quick_attr :one,:two,:three
	h = Hello.new.one([]).two(1,2,3,4,5).three(nil)

	assert_equal [], h.one
	assert_equal [1,2,3,4,5], h.two
	assert_equal nil, h.three
end

def test_proc
	Hello.quick_attr :one,:two
	h = Hello.new.one{true}.two(proc {3})
	assert_equal true, h.one.call
	assert_equal 3, h.two.call
	begin
		h.one ("args") {"fashl"}
		fail "set either a block or a value... not both"
	rescue; end
end

end

