@icon('../icon/target.svg')
class_name BTSelector
extends BTComposite

## The Selector node tries to execute each of its children one by one, in the order they are connected. 
## It reports a SUCCESS status code if any child reports a SUCCESS. If all children report a FAILURE 
## status code, the Selector node also returns FAILURE.
##
## Every tick, the Selector node processes all its children, even if one of them is currently RUNNING.

func tick(actor:Node, data:Dictionary):
	for child in get_children():
		if child is BTNode:
			var response = child.tick(actor, data)
			if response != STATUS.FAILURE:
				return response
	return STATUS.FAILURE
