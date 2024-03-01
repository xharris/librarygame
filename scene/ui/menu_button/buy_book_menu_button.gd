extends GameMenuButton

var books:Array[Book] = []

func get_card_objects():
	return Book.GENRE.values().map(func(v):
		var item = build_item(Book.GENRE.find_key(v)+'_BOOK', true)
		item.merge({ 'genre':v })
		return item)
		
func on_item_pressed(index:int):
	var object := objects[index] as Dictionary
	var genre := object.get('genre') as Book.GENRE
	var manager = GameManager.get_current()
	var popup = get_popup()
	if popup.is_item_checked(index):
		manager.disable_genre_research(genre)
	else:
		manager.enable_genre_research(genre)

func _process(delta):
	var manager = GameManager.get_current()
	var popup = get_popup()
	for g in Book.GENRE.size():
		var genre := Book.GENRE.values()[g] as Book.GENRE
		popup.set_item_checked(g, manager.genre_research.has(genre))
