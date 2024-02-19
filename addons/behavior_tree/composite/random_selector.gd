@icon('../icon/help-circle-composite.svg')
class_name BTRandomSelector
extends BTComposite

var _random_child:BTNode

func tick(actor:Node, data:Dictionary):
	if not _random_child:
		_random_child = get_children().pick_random()
	if _random_child:
		var response = _random_child.tick(actor, data)
		log_node_status(_random_child, response)
		if response != STATUS.RUNNING:
			_random_child = null
			return response
	return STATUS.FAILURE
