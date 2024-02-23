extends State

## TODO NEXT figure out navgiation layers so that actors arent walking through chairs but can still access them in sit state

@export var actor:Actor
var chair:Station
var duration:int = 0

var l = Log.new()

func get_distance(other:Node2D):
	return actor.global_position.distance_to(other.global_position)

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
	
	# find nearest chair
	chair = null
	var chairs:Array[Station] = []
	chairs.assign(StationHelper.get_all().filter(func(n:Station):
		return n.can_use(actor) and n.type == Station.STATION_TYPE.SEAT)
	)
	chairs.sort_custom(func(a:Station,b:Station):return get_distance(a) < get_distance(b))
	# go to chair
	if chairs.size():
		chair = chairs.front()
		l.debug('%s move to chair %s', [actor, chair])
		actor.move_to(chair.global_position)
		return
	# sit on the ground somewhere
	var random_tile = TileMapHelper.get_random_tilemap_cell(actor.random_tile_filter)
	if random_tile.is_valid():
		l.debug('%s move to random tile %s', [actor, random_tile.cell])
		actor.move_to(random_tile.map_to_global())
		return
	# nowhere to sit
	return stop_and_sit()

func _on_navigation_agent_2d_target_reached():
	stop_and_sit()

func _on_actor_navigation_blocked():
	stop_and_sit()
