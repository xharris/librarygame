class_name ActorStateMachine
extends StateMachine

@export var actor: Actor
@export var nav_agent: NavigationAgent2D
@export var animation: AnimationPlayer

func get_task_manager() -> TaskManager:
	return get_parent().find_child('TaskManager') as TaskManager

func _ready():
	super._ready()
	set_state('Walk')

func _on_add_state(node):
	if node is Task:
		node.actor = actor
		node.nav_agent = nav_agent
		node.animation = animation
