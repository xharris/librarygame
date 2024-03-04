extends ActionLeaf

var item:Item
var book:Book
@export var inspector_key:String
const INSPECTIN_SECTION = 'READING'
var inspection:Array[Dictionary] = []
var progress:int = 0
@onready var timer:Timer = $Timer
var started = false

func _process(delta):
	if not started:
		progress = 0
	else:
		progress = (timer.wait_time - timer.time_left) / timer.wait_time * 100

func tick(actor, _blackboard: Blackboard):
	actor = actor as Actor
	if not actor:
		return FAILURE
	# get first book in inventory
	if not book:
		var items = actor.inventory.get_all_items().filter(func(i:Item):return i.type == Item.TYPE.BOOK)
		if not items.size():
			return FAILURE
		item = items.front()
		book = Book.from_item(item)
	var bookmark = book.get_bookmark(actor)
	if not started:
		timer.wait_time = book.get_read_time(bookmark)
		timer.start()
		started = true
	# inspection
	inspection = [InspectProgress.build('progress', item.item_name, false)]
	InspectCard.add_properties(actor, inspection, self, INSPECTIN_SECTION)
	if progress >= 100:
		InspectCard.remove_properties(actor, inspection)
		var manager = GameManager.get_current()
		if manager:
			manager.apply_money(5, 'GOOD_READ')
		return SUCCESS
	return RUNNING

func interrupt(actor, _blackboard: Blackboard):
	timer.stop()
	started = false
