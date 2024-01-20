# meta-name: Task
class_name Task
extends State

var random_pickable = false
var required_previous_state:Array[String] = []

var actor: Actor
var nav_agent: NavigationAgent2D
var animation: AnimationPlayer

func is_task_needed() -> bool:
	return false
