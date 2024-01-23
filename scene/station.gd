class_name Station
extends Area2D

@export var title:String = 'Station'
@export var description:String = ''
@export var flavor_text:String = ''
@export var sprite:Node2D
@export var max_occupancy = 1
@export var type:StationHelper.STATION_TYPE
@export var sit_offset = Vector2(0,1)

var users:Array[Node2D] = []

func can_use():
	return users.size() < max_occupancy

func use(node:Node2D):
	if type == StationHelper.STATION_TYPE.SEAT:
		if node is Actor:
			node.global_position = global_position
			node.sprite_transform.position += sit_offset
		else:
			node.global_position = global_position
		if node is CharacterBody2D:
			node.velocity = Vector2.ZERO
		node.scale.x = scale.x
	users.append(node)

func done_using(node:Node2D):
	if node is Actor:
		node.sprite_transform.position -= sit_offset
	users = users.filter(func(u:Node): return u != node)
	
func _ready():
	add_to_group('station')
