extends Node

func get_using(node:Actor) -> Array[Station]:
	var stations:Array[Station]
	stations.assign(get_tree().get_nodes_in_group(Station.GROUP).filter(func(s:Station):return s.has_user(node)))
	return stations

func free_all_stations_by_type(node:Actor, type:Station.STATION_TYPE):
	var stations:Array[Station] = get_using(node).filter(func(s:Station): return s.type == type)
	for station in stations:
		station.done_using(node)

func get_all() -> Array[Station]:
	var stations:Array[Station]
	stations.assign(get_tree().get_nodes_in_group(Station.GROUP) as Array[Station])
	return stations
