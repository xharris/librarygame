extends BTAction

@export var station_key:String
@export var cleanup:bool = true

func tick(actor:Actor, data:Dictionary) -> STATUS:
	var station = data.get(station_key) as Station
	station.use(actor)
	if cleanup:
		data.erase(station_key)
	return success('Using station %s'%[station])
