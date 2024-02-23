extends ConditionLeaf

@export var station_key:String

func tick(actor, blackboard: Blackboard):
	var station := blackboard.get_value(station_key) as Station
	if station.has_user(actor):
		return SUCCESS
	return FAILURE
