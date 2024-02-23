extends ActionLeaf

@export var station_key:String

func tick(actor, blackboard: Blackboard):
	var station = blackboard.get_value(station_key) as Station
	station.use(actor)
	if actor is Actor and station.type == Station.STATION_TYPE.SEAT:
		actor.sit()
	return SUCCESS
