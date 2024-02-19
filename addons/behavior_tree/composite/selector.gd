class_name BTSelector
extends BTComposite

func tick(actor:Node2D, data:Dictionary):
	for child in get_children():
		if child is BTNode:
			var response = child.tick(actor, data)
			if response != STATUS.FAILURE:
				return response
	return STATUS.FAILURE
