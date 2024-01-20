extends Node

enum LAYER {
	_ZERO,
	FLOOR,
	WALL,
	NO_IDLE_FLOOR,
	ENTRANCE
}

func toggle_layers(nav_agent:NavigationAgent2D, layers:Array[LAYER], enable:bool):
	for layer in layers:
		nav_agent.set_navigation_layer_value(layer, enable)
