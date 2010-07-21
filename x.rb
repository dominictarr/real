class X

def new(*args)
puts "is this allowed?(#{args.join(',')})"

end
end

X.new.new(1,2,3,4)
