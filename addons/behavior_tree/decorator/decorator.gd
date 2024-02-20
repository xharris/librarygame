class_name BTDecorator
extends BTNode

func transform(response:STATUS, data:Dictionary) -> STATUS:
	return response

func tick(actor:Node, data:Dictionary):
	if get_child_count():
		var child = get_children().front()
		if child is BTNode:
			var response = child.tick(actor, data)
			return transform(response, data)
	return STATUS.SUCCESS
