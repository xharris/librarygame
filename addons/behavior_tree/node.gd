class_name BTNode
extends BehaviorTree

enum STATUS { RUNNING, SUCCESS, FAILURE }

func tick(actor, data:Dictionary) -> STATUS:
	return STATUS.FAILURE
