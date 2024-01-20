extends State

@export var body: Actor
@export var nav_agent: NavigationAgent2D
@onready var timer = $IdleTimer

var r = 0
func pick_new_state():
	# finish tasks
	var task_man = fsm.get_task_manager()
	if task_man and task_man.start_next_task():
		return
	
	match r:
		0:
			# walk to a random spot
			body.move_speed = 25
			var random_cell := TileMapHelper.get_random_tilemap_cell()
			if random_cell.is_valid():
				NavigationHelper.toggle_layers(nav_agent, [NavigationHelper.LAYER.NO_IDLE_FLOOR], false)
				nav_agent.target_position = random_cell.map_to_global()
		1:
			# stand still
			body.velocity = Vector2.ZERO
			timer.start(3)
		2:
			# perform a random task
			if task_man and task_man.start_random_task():
				return
			# sit
			fsm.set_state('Sit')
			
	r = Util.weighted_choice([20, 20, 50])
	
func enter(args:Dictionary):
	nav_agent.target_desired_distance = 10
	pick_new_state()

func _on_navigation_agent_2d_target_reached():
	body.velocity = Vector2.ZERO
	pick_new_state()
