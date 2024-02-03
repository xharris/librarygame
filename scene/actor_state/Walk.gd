extends State

var l = Log.new(Log.LEVEL.DEBUG)

var actor:Actor
var wandering = false

func _only_neighboring(cell:Vector2i, map:Map, target:Vector2):
	var target_coord = map.local_to_map(map.to_local(target))
	return (cell.x - target_coord.x) <= 1 and (cell.y - target_coord.y) <= 1 # TODO cell - target_coord <= Vector2i.ONE	

func enter(args:Dictionary):
	actor = find_parent('Actor') as Actor
	actor.navigation_blocked.connect(_on_actor_navigation_blocked)
	actor.nav_agent.target_reached.connect(_on_navigation_agent_2d_target_reached)
	
	var target := args.get('target', actor.global_position) as Vector2
	wandering = args.get('wandering', false) as bool
	
	## Only pick a neighboring tile when choosing a random tile
	var only_neighbors := args.get("only_neighbors", false) as bool

	StationHelper.free_all_stations_by_type(actor, Station.STATION_TYPE.SEAT)	
	# walk to given target
	if target != actor.global_position and actor.move_to(target, 25):
		return
	# walk to a random spot 
	var random_cell := TileMapHelper.get_random_tilemap_cell('nav', _only_neighboring.bind(target) if only_neighbors else Callable())
	if random_cell.is_valid() and \
		random_cell.map_to_global() != actor.global_position and \
		actor.move_to(random_cell.map_to_global()):
		return
	fsm.set_state('Idle', {}, 3 if wandering else 0)

func leave():
	actor.stop_moving()
	actor.animation.play('stand')
		
func _on_navigation_agent_2d_target_reached():
	l.debug('%s Target reached', [actor])
	if not actor.start_next_task():
		return fsm.set_state('Idle', {}, 3 if wandering else 0)

func _on_actor_navigation_blocked():
	if not actor.start_next_task():
		return fsm.set_state('Idle', {}, 3 if wandering else 0)
