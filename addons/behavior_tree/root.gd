@icon('./icon/Tree.svg')
class_name BTRoot
extends BehaviorTree

var data:Dictionary = {}

func _physics_process(delta):
	var actor := get_parent() as Node2D
	if not get_child_count() or not actor:
		return
	var child := get_children().front() as BTComposite
	child.tick(actor, data)
