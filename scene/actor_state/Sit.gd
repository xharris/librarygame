extends State

@export var actor:Actor
var chair:Station
var duration:int = 0

var l = Log.new(Log.LEVEL.DEBUG)

func get_distance(other:Node2D):
	return actor.global_position.distance_to(other.global_position)

func find_seat() -> Station:
	chair = null
	# find nearest chair
	var chairs:Array[Station] = []
	chairs.assign(StationHelper.get_all().filter(func(n:Station):
		return n.can_use(actor) and n.type == Station.STATION_TYPE.SEAT)
	)
	chairs.sort_custom(func(a:Station,b:Station):return get_distance(a) < get_distance(b))
	# go to chair
	if chairs.size():
		chair = chairs.front()
		l.debug('%s move to chair %s', [actor, chair])
		if actor.move_to(chair.global_position):
			return
	# sit on the ground somewhere
	var random_tile = TileMapHelper.get_random_tilemap_cell()
	if random_tile.is_valid() and actor.move_to(random_tile.map_to_global()):
		l.debug('%s sit random tile %s', [actor, random_tile.cell])
		return
	# nowhere to sit
	return stop_and_sit()

func stop_and_sit():
	# use chair if available
	if chair and not chair.can_use(actor):
		l.debug('%s cant use chair %s', [actor, chair])
		return fsm.set_state('Sit')
	if chair and chair.can_use(actor):
		chair.use(actor)
	# sit
	actor.stop_moving()
	actor.animation.play('sit')
	fsm.set_state('Idle', {}, duration)

func enter(args:Dictionary):	
	duration = args.get('duration', 0) as int
	find_seat()
	
func _on_navigation_agent_2d_target_reached():
	stop_and_sit()

func _on_actor_navigation_blocked():
	chair = null
	stop_and_sit()
