class_name Book
extends Node2D

enum LENGTH {SHORT, MEDIUM, LONG}

enum GENRE {
	FANTASY, SCIFI, DYSTOPIAN, ACTION, MYSTERY, HORROR, THRILLER, HISTORICAL, ROMANCE, GRAPHIC_NOVEL,
	DRAMA,
	GUIDE, BIOGRAPHY,
}
static var scene = preload('res://scene/item/book.tscn')
static var bookmarks = {}

static func build(genres:Array[GENRE] = [GENRE.ACTION], color:Color=Palette.Green500, pages:int = 1) -> Item:
	var item := Item.scene.instantiate() as Item
	var genre_name_gens:Array[Callable] = []
	for genre in genres:
		if NameGenerator.book_genre_name.has(genre):
			genre_name_gens.append(NameGenerator.book_genre_name[genre])
	if genre_name_gens.size():
		var name_gen:Callable = genre_name_gens.pick_random()
		item.item_name = name_gen.call()
	else:
		item.item_name = NameGenerator.book_name.call()
	item.args['genres'] = genres
	item.args['pages'] = pages
	item.add_texture('res://image/item/book_fill.png', color)
	item.add_texture('res://image/item/book_base.png')
	# add Book node
	var book := scene.instantiate() as Book
	item.add_child(book)
	
	return item

static func from_item(item:Item) -> Book:
	return item.get_children().filter(func(c):return c is Book).front()
	
static func random_genres(possible_genres:Array = GENRE.values()) -> Array[GENRE]:
	var genre_count = randi_range(1, 3)
	var genres:Array[GENRE] = []
	if not possible_genres.size():
		return genres
	for i in genre_count:
		var genre = possible_genres.pick_random()
		if possible_genres.size():
			genres.append(genre as GENRE)
		possible_genres = possible_genres.filter(func(g:GENRE):return g != genre)
	return genres

static func has_genres(item:Item, genres:Array[GENRE]) -> bool:
	var book_genres := item.args.get('genres', []) as Array[GENRE]
	return book_genres.any(func(g:GENRE):return genres.has(g))

var pages:int
var genres:Array[GENRE]
var length:LENGTH
var _genres_str = ''
var inspection:Array[Dictionary] = [
	InspectText.build('_genres_str')
]

func _ready():
	var item := find_parent('Item') as Item
	if item:
		InspectCard.add_properties(item, inspection, self)
	# pages
	pages = item.args.get('pages') as int
	# length
	match pages:
		var p when p <= 100:
			length = LENGTH.SHORT
		var p when p > 100 and p <= 500:
			length = LENGTH.MEDIUM
		var p when p > 500:
			length = LENGTH.LONG
	# genres
	genres = item.args.get('genres', [])	
	_genres_str = ', '.join(genres.map(func(g:GENRE):return GENRE.find_key(g)))

func get_read_time(pages_read:int = 0) -> int:
	var time = 3
	var remaining_length = length - pages_read
	match length:
		Book.LENGTH.SHORT:
			time = randi_range(10, 20)
		Book.LENGTH.MEDIUM:
			time = randi_range(20, 30)
		Book.LENGTH.LONG:
			time = randi_range(30, 40)
	return time

## Save number of pages read
func set_bookmark(actor:Actor, pages_read:int):
	if not bookmarks.has(actor):
		bookmarks[actor] = {}
	bookmarks[actor][self] = pages_read

## Get number of pages read
func get_bookmark(actor:Actor) -> int:
	if bookmarks.has(actor):
		return (bookmarks[actor] as Dictionary).get(self, 0)
	return 0
