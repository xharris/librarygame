extends ActionLeaf

@export var station_key:String

func tick(actor, blackboard: Blackboard):
	var station = blackboard.get_value(station_key) as Station
	station.done_using(actor)
	return SUCCESS

