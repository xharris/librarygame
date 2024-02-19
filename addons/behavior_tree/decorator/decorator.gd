class_name BTDecorator
extends BTNode

func transform(response:STATUS) -> STATUS:
	return response

func tick(actor:Node2D, data:Dictionary):
	var child = get_children().front()
	if child is BTNode:
		var response = child.tick(actor, data)
		return transform(response)
	return STATUS.SUCCESS
