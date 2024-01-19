extends Node

var fsm: ActorStateMachine
@export var body: Actor
@export var nav_agent: NavigationAgent2D
@onready var timer = $SitTimer
@export var sprite: Node2D
var chair:Station

func get_distance(other:Node2D):
	return body.global_position.distance_to(other.global_position)

func enter(args:Dictionary):	
	# find nearest chair
	var chairs:Array[Station]
	chairs.assign(get_tree().get_nodes_in_group('station').filter(func(n:Station):return n.can_use() and n.is_seat))
	chairs.sort_custom(func(a:Station,b:Station):return get_distance(a) < get_distance(b))
	if chairs.size():
		# go to chair
		chair = chairs.front() as Station
		nav_agent.target_desired_distance = 10
		nav_agent.target_position = chair.global_position
	else:
		# sit on the ground
		var random_tile := TileMapHelper.get_random_tilemap_cell()
		if not random_tile.is_valid():
			return fsm.set_state('Idle')
		nav_agent.target_desired_distance = 0
		nav_agent.target_position = random_tile.map_to_global()

func _on_navigation_agent_2d_target_reached():
	if chair:
		body.global_position = chair.global_position + Vector2(0, 1)
		sprite.scale.x = chair.scale.x
	var has_book = body.inventory.has_item_type(InventoryHelper.ITEM_TYPE.BOOK)
	if has_book:
		fsm.set_state('Read')
	else:
		# TODO sit for random_range seconds
		timer.start()

func _on_sit_timer_timeout():
	fsm.set_state('Idle')
