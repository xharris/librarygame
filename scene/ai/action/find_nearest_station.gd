extends ActionLeaf

@export var station_type:Station.STATION_TYPE
@export var station_key:String

func tick(actor, blackboard: Blackboard):
	var stations:Array[Station] = []
	stations.assign(
		StationHelper.get_all().filter(func(n:Station):
		return n.can_use(actor) and n.type == station_type)
	)
	Global.sort_distance(actor, stations)
	if stations.size():
		blackboard.set_value(station_key, stations.front())
		return SUCCESS
	return FAILURE
