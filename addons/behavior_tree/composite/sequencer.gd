@icon('../icon/rotate-cw.svg')
class_name BTSequencer
extends BTComposite

func tick(actor:Node, data:Dictionary):
	for child in get_children():
		if child is BTNode:
			var response = child.tick(actor, data)
			if response != STATUS.SUCCESS:
				return response
	return STATUS.SUCCESS
