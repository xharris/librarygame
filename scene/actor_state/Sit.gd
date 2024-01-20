extends State

@export var body: Actor
@export var nav_agent: NavigationAgent2D
@onready var timer = $SitTimer
@export var sprite: Node2D
@export var animation: AnimationPlayer


func get_distance(other:Node2D):
	return body.global_position.distance_to(other.global_position)

func stop_and_sit(chair:Node2D = null):
	# use chair if available
	if chair is Station:
		if chair.can_use() and chair.type == Station.STATION_TYPE.SEAT:
			chair.use(fsm.actor)
	# sit
	body.stop_moving()
	animation.play('sit')
	# move on
	var task_man := fsm.get_task_manager() as TaskManager
	if task_man and task_man.start_next_task():
		return
	else:
		timer.start()

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
		var chair := chairs.front() as Station
		nav_agent.target_position = chair.global_position
		animation.play('walk')
	else:
		# sit on the ground somewhere
		var random_tile := TileMapHelper.get_random_tilemap_cell()
		if not random_tile.is_valid():
			return stop_and_sit()
		nav_agent.target_position = random_tile.map_to_global()
		animation.play('walk')

func _physics_process(delta):
	if not nav_agent.is_navigation_finished():
		body.nav_move()
		body.face_move_direction()

func _on_sit_timer_timeout():
	fsm.set_state('Idle')

func _on_chair_detection_area_entered(area):
	stop_and_sit(area)

func _on_navigation_agent_2d_target_reached():
	stop_and_sit()
