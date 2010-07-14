class Setter
    attr_accessor :foo

    def initialize
        @foo = "It aint easy being cheesy!"
    end

    def set (&block)
        instance_eval &block if block
    end
end

options = Setter.new

# Works
options.instance_eval do
    p foo
end

# Fails
options.set do
    p foo
end
