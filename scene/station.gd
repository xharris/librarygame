class_name Station
extends Area2D

enum STATION_TYPE {SEAT}

@export var max_occupancy = 1
@export var type:STATION_TYPE


var occupied = false
var users:Array[Node] = []

func can_use():
	return users.size() < max_occupancy and not occupied
	
func _on_body_entered(body:Node2D):
	if body.is_in_group('actor'):
		users.append(body)

func _on_body_exited(body):
	if body.is_in_group('actor'):
		users = users.filter(func(u:Node): return u != body)
