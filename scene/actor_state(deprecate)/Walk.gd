extends State

var l = Log.new()

@export var actor:Actor
var target:Vector2
var wandering = false

func enter(args:Dictionary):	
	target = args.get('target', actor.global_position) as Vector2
	wandering = args.get('wandering', false) as bool
		
	# walk to given target
	if target != actor.global_position and actor.move_to(target, 25):
		actor.animation.play('walk')
		return
	# walk to a random spot 
	var random_cell := TileMapHelper.get_random_tilemap_cell(actor.random_tile_filter) as TileMapHelper.RandomTile
	var cell_source = TileMapHelper.get_current_map().get_cell_source_id(0, random_cell.cell)
	if random_cell.is_valid() and random_cell.map_to_global() != actor.global_position and actor.move_to(random_cell.map_to_global(), 25):
		actor.animation.play('walk')
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
