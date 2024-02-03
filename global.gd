extends Node

var l = Log.new()

## Callable that returns true
var CALLABLE_TRUE:Callable = func():return true

func tree() -> SceneTree:
	return get_tree()

## Returns first child of given type
func iterate_children_until(node:Node, matcher:Callable) -> Node:
	for child in node.get_children():
		if matcher.call(child):
			return child
		else:
			var ret = iterate_children_until(child, matcher)
			if ret:
				return ret
	return

func find_parent_by_type(node:Node, type:Variant) -> Variant:
	var parent = get_parent()
	while parent:
		if typeof(parent) == typeof(type):
			return parent
	return

var maps = [
	{
		map_name='Bird Library',
		scene=preload("res://map/FirstMap.tscn")
	}
]
