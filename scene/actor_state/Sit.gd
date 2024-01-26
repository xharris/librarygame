extends State

@export var body: Actor
@export var nav_agent: NavigationAgent2D
@onready var timer = $SitTimer
@export var sprite: Node2D
@export var animation: AnimationPlayer
@export var chair_detection:Area2D

var l = Log.new()
#var chair:Station

func get_distance(other:Node2D):
	return body.global_position.distance_to(other.global_position)

func find_seat() -> Station:
	# find nearest chair
	var chairs:Array[Station] = []
	chairs.assign(get_tree().get_nodes_in_group(Station.GROUP).filter(func(n:Station):
		return n.can_use() and n.type == StationHelper.STATION_TYPE.SEAT)
	)
	chairs.sort_custom(func(a:Station,b:Station):return get_distance(a) < get_distance(b))
	# go to chair
	if chairs.size():
		var chair = chairs.front()
		if body.move_to(chair.global_position):
			nav_agent.target_reached.connect(_on_navigation_agent_2d_target_reached_station.bind(chair), CONNECT_ONE_SHOT)
			return
	# sit on the ground somewhere
	var random_tile := TileMapHelper.get_random_tilemap_cell()
	if random_tile.is_valid() and body.move_to(random_tile.map_to_global()):
		nav_agent.target_reached.connect(_on_navigation_agent_2d_target_reached, CONNECT_ONE_SHOT)
		return
	# nowhere to sit
	return stop_and_sit()

func stop_and_sit(chair:Station = null):
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
	find_seat()

func _on_sit_timer_timeout():
	StationHelper.free_all_stations_by_type(fsm.actor, StationHelper.STATION_TYPE.SEAT)
	fsm.set_state('Walk')

func _on_navigation_agent_2d_target_reached_station(station:Station):
	stop_and_sit(station)
	
func _on_navigation_agent_2d_target_reached():
	stop_and_sit()

func _on_actor_navigation_blocked():
	stop_and_sit()
