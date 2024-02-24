class_name MapTile
extends Node2D

static var GROUP = 'maptile'

var cell:Vector2i
@onready var inventory:Inventory = $Inventory

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(GROUP)
	var map := TileMapHelper.get_current_map() as Map
	global_position = map.map_to_global(cell)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
