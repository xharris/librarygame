class_name PatronStateMachine
extends StateMachine

func _ready():
	set_state('Idle')

func _on_navigation_agent_2d_target_reached():
	state_callv('_on_nav_target_reached')
