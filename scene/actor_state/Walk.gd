extends State

@export var actor: Actor
@export var nav_agent: NavigationAgent2D
@export var animation: AnimationPlayer
@export var sprite_direction: Node2D

func enter(args:Dictionary):
	var target := args.get('target', fsm.actor.global_position) as Vector2	

	StationHelper.free_all_stations_by_type(actor, StationHelper.STATION_TYPE.SEAT)	
	NavigationHelper.toggle_layers(nav_agent, [NavigationHelper.LAYER.NO_IDLE_FLOOR, NavigationHelper.LAYER.ENTRANCE], false)
	# walk to given target
	if actor.move_to(target, 25):
		return
	# walk to a random spot
	var random_cell := TileMapHelper.get_random_tilemap_cell('nav')
	if random_cell.is_valid() and actor.move_to(random_cell.map_to_global()):
		return
	fsm.set_state('Idle')

func _process(delta):
	if not nav_agent.is_target_reached():
		actor.nav_move()
		actor.face_move_direction()
		
func _on_navigation_agent_2d_target_reached():
	if not fsm.get_task_manager().start_next_task():
		return fsm.set_state('Idle')
