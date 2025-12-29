class_name Move


var start: Vector2i
var end: int

func _init(start: Vector2i, end: int):
	self.start = start
	self.end = end

func print():
	print(str(start) + " :: " + str(end))
