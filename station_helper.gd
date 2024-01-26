extends Node

enum STATION_TYPE {SEAT,STORAGE}

func get_using(node:Node2D) -> Array[Station]:
	var stations:Array[Station]
	stations.assign(get_tree().get_nodes_in_group('station').filter(func(s:Station):return s.users.has(node)))
	return stations

func free_all_stations_by_type(node:Node2D, type:STATION_TYPE):
	var stations:Array[Station] = get_using(node).filter(func(s:Station): return s.type == type)
	for station in stations:
		station.done_using(node)

func get_all() -> Array[Station]:
	var stations:Array[Station]
	stations.assign(get_tree().get_nodes_in_group('station') as Array[Station])
	return stations
