extends State

@export var body: Actor
@export var nav_agent: NavigationAgent2D
@export var animation: AnimationPlayer
@onready var timer = $IdleTimer

func pick_new_state():
	# finish tasks
	var task_man = fsm.get_task_manager()
	if task_man and task_man.start_next_task():
		return
	# choose a random activity
	match Util.weighted_choice([20, 20, 50]):
		0:
			# walk to a random spot
			return fsm.set_state('Walk')
		1:
			# stand still
			timer.start(3)
		2:
			# perform a random task
			if task_man and task_man.start_random_task():
				return
			# sit
			return fsm.set_state('Sit')
	
func enter(args:Dictionary):
	nav_agent.target_desired_distance = 10
	pick_new_state()

func _on_navigation_agent_2d_target_reached():
	body.stop_moving()
	animation.play('stand')
	pick_new_state()
