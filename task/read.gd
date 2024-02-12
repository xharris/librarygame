class_name Read
extends Task

@onready var timer:Timer = $ReadTimer
@onready var progress_bar:ProgressBar = $ProgressBar
var current_book:int = Item.ID_NONE
var book_list:Array[int]
## Stores how many pages have been read in a book
var bookmarks:Dictionary = {}
var progress:int = 0
var inspection:Array[Dictionary] = [InspectProgress.build('progress', 'read')]

func is_task_needed() -> bool:
	return book_list.size() > 0

func can_start_task():
	return book_list.any(func(b:int):return actor.inventory.has_item(b))
	
func get_prep_steps():
	if not actor.inventory.get_all_items().any(func(i:Item):return i.id in book_list):
		# go get a book
		add_prep_state('GetItem', { item_filter=func(item:Item.ItemTemplate):return item.id in book_list })
	if not Station.is_using_type(actor, Station.STATION_TYPE.SEAT):
		add_prep_state('Sit')

func enter(args:Dictionary):
	current_book = book_list.pick_random()
	var book := actor.inventory.get_item(current_book).get_wrapper() as Book
	var time = 3
	var pages_read := bookmarks.get(current_book, 0) as int
	var remaining_length = book.get_length(pages_read)
	match book.get_length(pages_read):
		Book.LENGTH.SHORT:
			time = randi_range(10, 20)
		Book.LENGTH.MEDIUM:
			time = randi_range(20, 30)
		Book.LENGTH.LONG:
			time = randi_range(30, 40)
	progress_bar.value = pages_read / book.pages * 100
	l.debug('%s started reading, start_page=%d length_remaining=%s time=%d', 
		[actor, pages_read, Book.LENGTH.find_key(remaining_length), time])
	timer.start(time)
	progress_bar.show()
	InspectCard.add_properties(actor, inspection, self)

func leave():
	timer.paused = true
	if timer.time_left > 0:
		# didn't finish reading, store a 'bookmark'
		var progress = (timer.wait_time - timer.time_left) / timer.wait_time
		l.info('%s reading progress %d%%', [actor, progress * 100])
		var book := actor.inventory.get_item(current_book).get_wrapper() as Book
		bookmarks[current_book] = progress * book.pages
		# TODO happiness--
	else:
		# finished reading 
		l.info('%s finished reading', [actor])
		# TODO happiness++
		book_list = book_list.filter(func(b:int):return b != current_book)
		if bookmarks.has(current_book):
			bookmarks.erase(current_book)
		current_book = Item.ID_NONE
	timer.stop()
	progress_bar.hide()
	InspectCard.remove_properties(actor, inspection)

func _ready():
	# create a list of books to read
	var available_books = Book.get_all_templates()
	for i in randi_range(1, min(3, available_books.size())):
		var book = available_books.pick_random() as Item.ItemTemplate
		book_list.append(book.id)
		available_books = available_books.filter(func(i:Item.ItemTemplate):return i.id == book.id)

func _process(delta):
	var weight = 0
	if timer.wait_time > 0:
		weight = (timer.wait_time - timer.time_left) / timer.wait_time
	progress_bar.value = lerp(0, 100, weight)
	progress = progress_bar.value

func _on_read_timer_timeout():
	fsm.set_state('Idle')
