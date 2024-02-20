@icon('../icon/help-circle-composite.svg')
class_name BTRandomSelector
extends BTComposite

var _children:Array[BTNode]

func _ready():
	_children.assign(get_children())
	_children.shuffle()

func tick(actor:Node, data:Dictionary):
	for child in _children:
		if child is BTNode:
			var response = child.tick(actor, data)
			if response != STATUS.FAILURE:
				return response
	return STATUS.FAILURE
