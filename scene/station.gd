class_name Station
extends Area2D

enum STATION_TYPE {SEAT}

@export var max_occupancy = 1
@export var type:STATION_TYPE

var users:Array[Node2D] = []

func can_use():
	return users.size() < max_occupancy

func use(node:Node2D):
	if type == STATION_TYPE.SEAT:
		node.global_position = global_position + Vector2(0, 1)
		if node is CharacterBody2D:
			node.velocity = Vector2.ZERO
		node.scale.x = scale.x
	users.append(node)

func done_using(node:Node2D):
	users = users.filter(func(u:Node): return u != node)
	
func _ready():
	add_to_group('station')
