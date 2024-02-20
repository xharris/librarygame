extends ActionLeaf

@export var station_type:Station.STATION_TYPE
@export var station_key:String

func tick(actor, blackboard: Blackboard):
	var stations:Array[Station] = []
	stations.assign(StationHelper.get_all().filter(func(n:Station):
		return n.can_use(actor) and n.type == station_type)
	)
	stations.sort_custom(func(a:Station,b:Station):
		return actor.global_position.distance_to(a.global_position) < actor.global_position.distance_to(b.global_position))
	if stations.size():
		blackboard.set_value(station_key, stations.front())
		return SUCCESS
	return FAILURE
