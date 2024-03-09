extends Node

# static var NAME_TEMPLATE = [
# 	"The {adj1} {noun1}", 
# 	"{noun1} of {noun2}", 
# 	"{adj1} {noun1}, {adj2} {noun2}"
# ]
# static var NAME_PARTS = {
# 	adj = ['poor', 'rich', 'bloody', 'wild', 'secret'],
# 	noun = ['dad', 'mom', 'heart', 'man', 'woman', 'kid', 'agent', 'killer'],
# }
# var gen = NameGenerator.new(NAME_TEMPLATE, NAME_PARTS)
# gen() --> The Poor Man

func build(templates:Array[String], _parts:Dictionary) -> Callable:
	var res = func generate_name():
		var random_template = templates.pick_random()
		var parts:Array[String] = []
		parts.assign(_parts.keys())
		var template_args = {}
		for part in parts:
			var i = 1
			while '{'+part+str(i)+'}' in random_template:
				var possible_parts:Array[String] = []
				possible_parts.assign(_parts[part])
				var arg := possible_parts.pick_random() as String
				template_args[part+str(i)] = arg.capitalize()
				i += 1
		return random_template.format(template_args)
	return res

var actor_name = build(
	["Mr. {lastname1}", "Sir {firstname1} {lastname1}", "{firstname1} Jr"],
	{
		firstname=["Patrick", "Ryan"],
		lastname=["Bigglesworth", "Stewart", "Johnson"],
	}
)

var _book_templates:Array[String] = [
	"The {adj1} {noun1}", 
	"{adj1} {noun1} of {plural1}", 
	"{adj1} {noun1}, {adj2} {noun2}",
	"{number1} {adj1} {plural1}"
]
var _w_list:Array[String] = ['what', 'when', 'where', 'how', 'why']
var book_name = build(
	_book_templates,
	{
		adj=['boring', 'bland', 'empty'],
		noun=['list', 'person', 'thing'],
		number=['one million', 'a few', 'zero'],
		plural=['lists', 'people', 'things'],
		w=_w_list
	}
)

var book_genre_name:Dictionary = {
	Book.GENRE.DRAMA:build(_book_templates,{
		adj=['sad','moody','desirable','lovely','little','gone'],
		noun=['girl','boy','mom','dad','woman','man'],
		plural=[''],
		w=_w_list
	})
}
