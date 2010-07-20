#more demonstrations of the need to call eval in a clean context for sensible behaviour.

eval ("puts x; x = 100")

eval ("puts x")

puts x

#x = 1

proc {puts y} .call

#puts y
y = 1
