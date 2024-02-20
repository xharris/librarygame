@icon('./icon/trello.svg')
class_name BTRoot
extends BehaviorTree

var data:Dictionary = {}
var _actor:Node

func _enter_tree():
	_actor = get_parent()

func _physics_process(delta):
	_actor = get_parent()
	if not get_child_count() or not _actor:
		return
	var child := get_children().front() as BTComposite
	child.tick(_actor, data)
