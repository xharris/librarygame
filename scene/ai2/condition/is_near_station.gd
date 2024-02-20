extends ConditionLeaf

@export var station_key:String

func tick(actor, blackboard: Blackboard):
	var station = blackboard.get_value(station_key) as Station
	if station.global_position.distance_to((actor as Node2D).global_position) < 5:
		return SUCCESS
	return FAILURE

