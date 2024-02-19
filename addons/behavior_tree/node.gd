class_name BTNode
extends BehaviorTree

enum STATUS { RUNNING, SUCCESS, FAILURE }

func tick(actor:Node2D, data:Dictionary) -> STATUS:
	return STATUS.FAILURE
