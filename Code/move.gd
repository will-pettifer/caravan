class_name Move


var start: int
var end: int

func _init(start: int, end: int):
	self.start = start
	self.end = end


func equals(other: Move):
	return other.start == start and other.end == end


func print():
	return str(start) + " -> " + str(end)
