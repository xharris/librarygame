extends State

@export var nav_agent: NavigationAgent2D
@export var animation: AnimationPlayer
@export var sprite_direction: Node2D

var is_random_spot = false

func _only_neighboring(cell:Vector2i, map:Map, target:Vector2):
	var target_coord = map.local_to_map(map.to_local(target))
	return (cell.x - target_coord.x) <= 1 and (cell.y - target_coord.y) <= 1 # TODO cell - target_coord <= Vector2i.ONE	

func enter(args:Dictionary):
	var target := args.get('target', fsm.actor.global_position) as Vector2
	## Only pick a neighboring tile when choosing a random tile
	var only_neighbors := args.get("only_neighbors", false) as bool

	StationHelper.free_all_stations_by_type(fsm.actor, StationHelper.STATION_TYPE.SEAT)	
	# walk to given target
	if target != fsm.actor.global_position and fsm.actor.move_to(target, 25):
		return
	# walk to a random spot 
	var random_cell := TileMapHelper.get_random_tilemap_cell('nav', _only_neighboring.bind(target) if only_neighbors else Callable())
	if random_cell.is_valid() and fsm.actor.move_to(random_cell.map_to_global()):
		is_random_spot = true
		NavigationHelper.toggle_layers(nav_agent, [NavigationHelper.LAYER.NO_IDLE_FLOOR, NavigationHelper.LAYER.ENTRANCE], true)
		return
	fsm.set_state('Idle')

func leave():
	if is_random_spot:
		is_random_spot = false
		NavigationHelper.toggle_layers(nav_agent, [NavigationHelper.LAYER.NO_IDLE_FLOOR, NavigationHelper.LAYER.ENTRANCE], false)
	fsm.actor.stop_moving()
	animation.play('stand')
		
func _on_navigation_agent_2d_target_reached():
	if not fsm.get_task_manager().start_next_task():
		return fsm.set_state('Idle')

func _on_actor_navigation_blocked():
	if not fsm.get_task_manager().start_next_task():
		return fsm.set_state('Idle')
