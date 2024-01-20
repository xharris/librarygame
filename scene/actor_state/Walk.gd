extends State

@export var actor: Actor
@export var nav_agent: NavigationAgent2D
@export var animation: AnimationPlayer
@export var sprite_direction: Node2D

func enter(args:Dictionary):
	var target := args.get('target', fsm.actor.global_position) as Vector2
	
	NavigationHelper.toggle_layers(nav_agent, [NavigationHelper.LAYER.NO_IDLE_FLOOR, NavigationHelper.LAYER.ENTRANCE], false)
	
	# walk to a random spot?
	if target.distance_to(fsm.actor.global_position) < 8:
		var random_cell := TileMapHelper.get_random_tilemap_cell()
		if random_cell.is_valid():
			target = random_cell.map_to_global()
			fsm.actor.move_speed = 25
	
	nav_agent.target_position = target
	animation.play('walk')
	print(fsm.actor.global_position,'->',target)

func leave():
	actor.velocity = Vector2.ZERO

func _process(delta):
	actor.nav_move()
	actor.face_move_direction()
		
func _on_navigation_agent_2d_target_reached():
	if not fsm.get_task_manager().start_next_task():
		return fsm.set_state('Idle')
