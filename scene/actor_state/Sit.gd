extends State

@export var body: Actor
@export var nav_agent: NavigationAgent2D
@onready var timer = $SitTimer
@export var sprite: Node2D
@export var animation: AnimationPlayer

var sit_attempts = 3
var chair:Station

func get_distance(other:Node2D):
	return body.global_position.distance_to(other.global_position)

func find_seat():
	# nowhere to sit
	if sit_attempts <= 0:
		return stop_and_sit()
	# find nearest chair
	var chairs:Array[Station] = []
	chairs.assign(get_tree().get_nodes_in_group('station').filter(func(n:Station):
		return n.can_use() and n.type == StationHelper.STATION_TYPE.SEAT)
	)
	chairs.sort_custom(func(a:Station,b:Station):return get_distance(a) < get_distance(b))
	# go to chair
	if chairs.size() and body.move_to((chairs.front() as Station).global_position):
		chair = chairs.front()
		return
	# sit on the ground somewhere
	var random_tile := TileMapHelper.get_random_tilemap_cell()
	if random_tile.is_valid() and body.move_to(random_tile.map_to_global()):
		return
	sit_attempts -= 1
	find_seat()

func stop_and_sit():
	# use chair if available
	if chair is Station and (chair as Station).type == StationHelper.STATION_TYPE.SEAT:
		if chair.can_use():
			chair.use(fsm.actor)
		else:
			return find_seat()
	# sit
	body.stop_moving()
	animation.play('sit')
	# move on
	var task_man := fsm.get_task_manager() as TaskManager
	if task_man and task_man.start_next_task():
		return
	timer.start()

func enter(_args:Dictionary):
	nav_agent.target_desired_distance = 10
	find_seat()

func leave():
	StationHelper.free_all_stations_by_type(fsm.actor, StationHelper.STATION_TYPE.SEAT)

func _process(delta):
	if not nav_agent.is_navigation_finished():
		if body.velocity != Vector2.ZERO:
			animation.play('walk')
		else:
			animation.play('stand')

func _physics_process(delta):
	if not nav_agent.is_navigation_finished():
		body.nav_move()
		body.face_move_direction()

func _on_sit_timer_timeout():
	fsm.set_state('Idle')

func _on_chair_detection_area_entered(area):
	chair = area
	stop_and_sit()

func _on_navigation_agent_2d_target_reached():
	stop_and_sit()
