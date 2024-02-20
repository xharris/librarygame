extends BTAction

func tick(actor:Actor, data:Dictionary) -> STATUS:
	actor.stop_moving()
	return success('Standing')
