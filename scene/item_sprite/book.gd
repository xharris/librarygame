class_name Book
extends Object

enum LENGTH {SHORT, MEDIUM, LONG}

enum GENRE {
	FANTASY, SCIFI, DYSTOPIAN, ACTION, MYSTERY, HORROR, THRILLER, HISTORICAL, ROMANCE, GRAPHIC_NOVEL,
	DRAMA,
	GUIDE, BIOGRAPHY,
}

static func build(genres:Array[GENRE] = [GENRE.ACTION], color:Color=Palette.Green500, pages:int = 1) -> Item:
	var item := Item.scene.instantiate() as Item
	item.item_name = NameGenerator.book_name.call()
	item.args['genres'] = genres
	item.args['pages'] = pages
	item.add_texture('res://image/item/book_fill.png', color)
	item.add_texture('res://image/item/book_base.png')
	return item

static func from_item(item:Item) -> Book:
	var book = Book.new()
	book.pages = item.args.get('pages') as int
	# length
	match book.pages:
		var p when p <= 100:
			book.length = LENGTH.SHORT
		var p when p > 100 and p <= 500:
			book.length = LENGTH.MEDIUM
		var p when p > 500:
			book.length = LENGTH.LONG
	return book

static func random_genres() -> Array[GENRE]:
	var possible_genres = GENRE.values()
	var genre_count = randi_range(1, 3)
	var genres:Array[GENRE] = []
	for i in genre_count:
		var genre = possible_genres.pick_random()
		if possible_genres.size():
			genres.append(genre)
		possible_genres = possible_genres.filter(func(g:int):return g != genre)
	return genres

var pages:int
var genres:Array[GENRE]
var length:LENGTH
	
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
