class_name ActorStateMachine
extends StateMachine

func _ready():
	super._ready()
	set_state('Read')

func _on_navigation_agent_2d_target_reached():
	state_callv('_on_nav_target_reached')
