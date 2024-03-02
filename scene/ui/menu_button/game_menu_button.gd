class_name GameMenuButton
extends MenuButton

static var l = Log.new()

var objects:Array[Variant] = []

func get_card_objects() -> Array[Variant]:
	return []

func on_item_pressed(index:int):
	pass

func _on_item_pressed(index:int):
	on_item_pressed(index)

func build_item(text_key:String, is_checkbox:bool = false, action:Variant = null) -> Dictionary:
	return {'text_key':text_key,'is_checkbox':is_checkbox,'action':action}

func build_separator(text_key:String = ''):
	return {'text_key':text_key,'is_separator':true}

func _ready():
	var cards:Array[SmallCard] = []
	objects = get_card_objects()
	var pp = get_popup()
	pp.hide_on_checkable_item_selection = false
	# add menu button item
	for object in objects:
		var node:Node
		var text_key:String
		var is_checkbox:bool = false
		var is_separator:bool = false
		if object is Dictionary:
			text_key = object.get('text_key')
			is_checkbox = object.get('is_checkbox', false) as bool
			is_separator = object.get('is_separator', false) as bool
			object = object.get('object')
		if is_separator:
			pp.add_separator(text_key)
			continue
		if object is PackedScene:
			node = object.instantiate()
			node.process_mode = Node.PROCESS_MODE_DISABLED
		if object is Node:
			node = node
		if object is String:
			text_key = object.to_upper()
		if node:
			text_key = node.name.to_upper()
		if not text_key:
			return l.error("Couldn't extract text_key from %s",[object])
		pp.add_item("%s_TITLE" % text_key)
		var i = pp.item_count - 1
		if is_checkbox:
			pp.set_item_as_checkable(i, true)
		pp.set_item_tooltip(i, tr("%s_DESCRIPTION" % text_key).strip_edges())
	# on item select
	pp.index_pressed.connect(_on_item_pressed)
