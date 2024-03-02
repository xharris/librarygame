extends GameMenuButton

enum ACTION {TOGGLE_RESEARCH, FORCE_DELIVERY}
var books:Array[Book] = []
var force_delivery_idx = 0

func get_card_objects():
	var objects = Book.GENRE.values().map(func(v):
		var item = build_item(Book.GENRE.find_key(v)+'_BOOK',true,ACTION.TOGGLE_RESEARCH)
		item.merge({ 'genre':v })
		return item)
	objects.append(build_separator())
	objects.append(build_item('FORCE_BOOK_DELIVERY',false,ACTION.FORCE_DELIVERY))
	force_delivery_idx = objects.size()-1
	return objects
	
func on_item_pressed(index:int):
	var object := objects[index] as Dictionary
	var action := object.get('action') as ACTION
	var manager = GameManager.get_current()

	# book research
	if action == ACTION.TOGGLE_RESEARCH:
		var genre := object.get('genre') as Book.GENRE
		var popup = get_popup()
		# book research
		if manager.genre_research.has(genre):
			manager.disable_genre_research(genre)
		else:
			manager.enable_genre_research(genre)
		
	# force delivery
	if action == ACTION.FORCE_DELIVERY:
		manager.research_book(true)

func _process(delta):
	var manager = GameManager.get_current()
	var popup = get_popup()
	for g in Book.GENRE.size():
		var genre := Book.GENRE.values()[g] as Book.GENRE
		popup.set_item_checked(g, manager.genre_research.has(genre))
	popup.set_item_disabled(force_delivery_idx, manager.genre_research.size() == 0)
