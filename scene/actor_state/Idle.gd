extends State

@export var actor:Actor
var sitting = false

func enter(args:Dictionary):
	actor.stop_moving()
	
	# finish tasks
	if actor.start_next_task():
		return
		
	var stations = StationHelper.get_using(actor)
	if stations.size():
		for station in stations:
			station.done_using(actor)
		return fsm.set_state('Walk', {wandering=true})
		
	# choose a random activity
	match Util.weighted_choice([30, 20, 50]):
		0:
			# walk to a random spot
			return fsm.set_state('Walk', {wandering=true})
		1:
			# do nothing
			fsm.set_state('Idle', {}, 3)
		2:
			# sit
			sitting = StationHelper.get_using(actor).filter(func(s:Station):return s.type == Station.STATION_TYPE.SEAT).size() > 0
			if sitting:
				fsm.set_state('Idle', {}, 3)
				return
			else:
				return fsm.set_state('Sit', {duration=3})
