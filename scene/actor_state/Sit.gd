extends State

@export var body: Actor
@export var nav_agent: NavigationAgent2D
@onready var timer = $SitTimer
@export var sprite: Node2D
@export var animation: AnimationPlayer
var chair:Station

func get_distance(other:Node2D):
	return body.global_position.distance_to(other.global_position)

func enter(_args:Dictionary):
	nav_agent.target_desired_distance = 10
	# find nearest chair
	var chairs:Array[Station] = []
	chairs.assign(get_tree().get_nodes_in_group('station').filter(func(n:Station):
		return n.can_use() and n.type == Station.STATION_TYPE.SEAT)
	)
	chairs.sort_custom(func(a:Station,b:Station):return get_distance(a) < get_distance(b))
	if chairs.size():
		# go to chair
		chair = chairs.front() as Station
		nav_agent.target_position = chair.global_position
	else:
		# sit on the ground
		var random_tile := TileMapHelper.get_random_tilemap_cell()
		if not random_tile.is_valid():
			return fsm.set_state('Idle')
		nav_agent.target_position = random_tile.map_to_global()

func _on_navigation_agent_2d_target_reached():
	body.velocity = Vector2.ZERO
	if chair and chair.can_use():
		body.global_position = chair.global_position + Vector2(0, 1)
		body.scale.x = chair.scale.x
	animation.play('sit')
	var task_man := fsm.get_task_manager() as TaskManager
	if task_man and task_man.start_next_task():
		return
	else:
		timer.start()

func _on_sit_timer_timeout():
	fsm.set_state('Idle')
