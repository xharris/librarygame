extends ActionLeaf

@export var int_min:int = 0
@export var int_max:int = 100
@export var random_key:String

func tick(actor:Node, data:Blackboard):
	data.set_value(random_key, randi_range(int_min, int_max))
	return SUCCESS
