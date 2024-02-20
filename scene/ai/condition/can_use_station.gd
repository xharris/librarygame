extends BTCondition

@export var station_key:String

func tick(actor, data:Dictionary) -> STATUS:
	var station = data.get(station_key) as Station
	if station.can_use(actor):
		return success('Can use %s %s' % [Station.STATION_TYPE.find_key(station.type), station])
	return failure('Cannot use %s %s' % [Station.STATION_TYPE.find_key(station.type), station])
