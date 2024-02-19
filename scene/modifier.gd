class_name Modifier
extends Node2D

static var scene = preload('res://scene/modifier.tscn')
static var _modifier_data = {}
static var _modifier_section = {}
static var _next_id = 0

static func register(_name:String, section_name:String = ''):
	var id = _next_id
	_modifier_data[id] = _name
	_modifier_section[id] = section_name
	_next_id += 1
	return id

static func get_all(node:Node) -> Array[Modifier]:
	var mods:Array[Modifier] = []
	mods.assign(node.get_children().filter(func(c):return c is Modifier))
	return mods

static func has_modifier(node:Node, id:int) -> bool:
	return node.get_children().filter(func(c):return c is Modifier and c.id == id).size() > 0
	
static func add_modifier(node:Node, id:int, section_name:String = '') -> Modifier:
	var mods = get_all(node).filter(func(m:Modifier):return m.id == id)
	var modifier:Modifier = mods.front()
	if modifier:
		# increase level
		modifier.level += 1
	else:
		modifier
		modifier = scene.instantiate() as Modifier
		modifier.id = id
		modifier.section_name = section_name
		node.add_child(modifier)
	Events.modifier_add.emit(node, modifier)
	return modifier
	
static func remove_modifier(node:Node, id:int):
	var modifiers = get_all(node).filter(func(m:Modifier):return m.id == id)
	for mod in modifiers:
		if mod.level > 0:
			# decrease level
			mod.level -= 1
		else:
			node.remove_child(mod)
			Events.modifier_remove.emit(node, mod)

## Returns modifier value if it exists, else returns `if_not_exist`
static func get_modifier_value(node:Node, id:int, if_not_exist:Variant) -> Variant:
	var modifiers = node.get_children().filter(func(c):return c is Modifier)
	if modifiers.size():
		return (modifiers.front() as Modifier).value
	return if_not_exist

var id:int
var modifier_name:String
var level:int = 1
var inspect_args:Array
var inspection:Array[Dictionary]
var section_name:String = ''

func _update_inspection_args():
	inspect_args = [modifier_name, level]

func _ready():
	# retrieve data
	modifier_name = _modifier_data.get(id) as String
	# inspection
	inspection = [
		InspectText.build('inspect_args', '{0} x{1}')
	]
	_update_inspection_args()
	var parent = get_parent()
	# section
	if not section_name.length() and _modifier_section.has(id):
		section_name = _modifier_section[id]
	InspectCard.add_properties(parent, inspection, self, section_name)

func _process(delta):
	_update_inspection_args()

func _exit_tree():
	var parent = get_parent()
	InspectCard.remove_properties(parent, inspection)
