extends Node

enum LAYER {
	_ZERO,
	FLOOR,
	NO_IDLE_FLOOR,
	NO_FLOOR
}

func toggle_agent_layers(nav_agent:NavigationAgent2D, layers:Array[LAYER], enable:bool):
	for layer in layers:
		nav_agent.set_navigation_layer_value(layer, enable)

func toggle_map_layers(cell:Vector2, layers:Array[LAYER], enable:bool):
	var maps := get_tree().get_nodes_in_group(Map.GROUP) as Array[Map]
	for map in maps:
		pass
