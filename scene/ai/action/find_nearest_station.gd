extends BTAction

@export var station_type:Station.STATION_TYPE
@export var station_key:String

func tick(actor:Actor, data:Dictionary) -> STATUS:
	if data.has(station_key):
		return STATUS.SUCCESS
	var stations:Array[Station] = []
	stations.assign(StationHelper.get_all().filter(func(n:Station):
		return n.can_use(actor) and n.type == station_type)
	)
	stations.sort_custom(func(a:Station,b:Station):
		return actor.global_position.distance_to(a.global_position) < actor.global_position.distance_to(b.global_position))
	if stations.size():
		data[station_key] = stations.front()
		return success("Found %s %s" % [Station.STATION_TYPE.find_key(station_type), stations.front()])
	return failure("Couldn't find %s" % [Station.STATION_TYPE.find_key(station_type)])
