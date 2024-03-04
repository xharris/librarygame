extends Node

var l = Log.new()

signal EMPTY_SIGNAL

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

func sort_distance(from:Node2D, to:Array[Variant]):
	to.sort_custom(func(a:Node2D,b:Node2D):
		return from.global_position.distance_to(a.global_position) < from.global_position.distance_to(b.global_position))

func sort_distance_vector2i(from:Vector2i, to:Array[Vector2i]):
	var from_vector2 = Vector2(from)
	to.sort_custom(func(a:Vector2i,b:Vector2i):
		return from_vector2.distance_to(Vector2(a)) < from_vector2.distance_to(Vector2(b)))

var INSPECT_SECTION = {
	BUFF = 'good',
	DEBUFF = 'bad',
	NEUTRAL = 'neutral',
}
