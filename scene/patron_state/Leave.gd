extends PatronStateMachine

@export var nav_agent: NavigationAgent2D

func enter():
	# leave library
	NavigationHelper.toggle_layers(nav_agent, [
		NavigationHelper.LAYER.NO_IDLE_FLOOR,
		NavigationHelper.LAYER.FLOOR
	], false)
