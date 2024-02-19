extends BTAction

func tick(actor:Actor, data:Dictionary) -> STATUS:
	actor.stop_moving()
	return STATUS.SUCCESS
