class_name GameManager
extends Node2D

static var l = Log.new()
static var GROUP = 'game_manager'
static var CYCLE_LENGTH = 600
static var COST_FORCE_DELIVERY = -5
static var COST_BOOK_DELIVERY = -5

static func get_current() -> GameManager:
	return Global.get_tree().get_nodes_in_group(GROUP).front() as GameManager

@export var initial_spawn_count = 1
@export var disable_random_spawning:bool
var game_time:float = 0
var cycle = 0
var cycle_progress:float = 0
var money = abs(COST_BOOK_DELIVERY)
var genre_research:Array[Book.GENRE] = []
var game_speed = 2.0 # TODO
var dt = DayNight.DateTime.new()

func apply_money(amount:int, reason:String) -> bool:
	if amount < 0 and money < amount:
		NotificationCard.show_notification(tr('INSUFFICIENT_FUNDS: %s'%[reason]))
		return false
	if amount > 0:
		NotificationCard.show_notification(tr('FUNDS_ADDED: %s'%[reason]))
	l.info('Money %d (%s)', [amount, reason])
	money += amount
	return true

func get_patron_count() -> int:
	var actors = Actor.get_all()
	return actors.filter(func(a:Actor): return a.role == Actor.ROLE.PATRON and a.is_active()).size()

func is_max_patrons() -> bool:
	var map := TileMapHelper.get_current_map() as Map
	var max_capacity := (map.get_used_cells(0).size() * 2/3)
	return get_patron_count() >= max_capacity

## Return [0,100] chance of spawning patron
func get_spawn_chance() -> int:
	var seat_count = get_tree().get_nodes_in_group(Station.GROUP).filter(func(s:Station):return s.type == Station.STATION_TYPE.SEAT and s.is_active()).size()
	var patron_count = get_patron_count()
	var book_count = Item.get_all().filter(func(i:Item):return i.type == Item.TYPE.BOOK).size()
	var weights = [
		(seat_count / patron_count) if patron_count > 0 else 0,
		(book_count / patron_count) if patron_count > 0 else 0
	]
	var spawn_chance = weights.reduce(func(prev,curr):return prev + curr, 0) / weights.size()
	return (spawn_chance if get_patron_count() >= initial_spawn_count else 1) * 25

func enable_genre_research(genre:Book.GENRE):
	if not genre_research.has(genre):
		genre_research.append(genre)

func disable_genre_research(genre:Book.GENRE):
	genre_research = genre_research.filter(func(g:Book.GENRE):return g != genre)

func research_book(forced:bool = false):
	if not genre_research.size():
		return
	if forced:
		if not apply_money(COST_FORCE_DELIVERY, 'FORCED_RESEARCH'):
			return
	var genres = Book.random_genres(genre_research)
	if not apply_money(COST_BOOK_DELIVERY * genres.size(), 'RESEARCH'):
		return
	var actor = Actor.build(Actor.ROLE.SERVICE)
	if genres.size():
		var item = Book.build(genres)
		var inventory := actor.find_child('Inventory') as Inventory
		inventory.add_item(item)
		var map := TileMapHelper.get_current_map() as Map
		map.spawn_actor(actor)
		var book = Book.from_item(item)

var _last_event_time = {}
func game_event(event:String, every:int):
	var last_time = _last_event_time.get(event, 0) as int
	if int(game_time) > 0 and last_time != int(game_time) and int(game_time) % every == 0:
		_last_event_time[event] = int(game_time)
		return true
	return false

func _ready():
	# TODO delete
	pass
	#for genre in Book.GENRE.values():
		#enable_genre_research(genre)
	#research_book()
	#for genre in Book.GENRE.values():
		#disable_genre_research(genre)

func _process(delta):
	game_time = max(0, game_time) + delta
	cycle = ceil(game_time / CYCLE_LENGTH)
	cycle_progress = (game_time - ((cycle - 1.0) * CYCLE_LENGTH)) / CYCLE_LENGTH
	dt.from_game_manager(self)
	# chance to spawn patron
	if game_event('spawn_patron', 1):
		var map := TileMapHelper.get_current_map() as Map
		var random = randi_range(1, 100)
		var spawn_chance = get_spawn_chance()
		l.debug('Spawn patron chance %d (rolled %d)', [spawn_chance, random])
		if not disable_random_spawning and not is_max_patrons() and random <= spawn_chance:
			l.debug('Spawned patron')
			map.spawn_actor(Actor.build(Actor.ROLE.PATRON))
	# buy a new book
	if game_event('book_research', CYCLE_LENGTH / 2):
		research_book()
