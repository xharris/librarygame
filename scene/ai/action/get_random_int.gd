extends BTAction

@export var int_min:int = 0
@export var int_max:int = 100
@export var random_key:String

func tick(actor, data:Dictionary) -> STATUS:
	if data.has(random_key):
		return success('Aready set')
	var random_int = randi_range(int_min, int_max)
	data[random_key] = random_int
	return success('%d'%[random_int])

