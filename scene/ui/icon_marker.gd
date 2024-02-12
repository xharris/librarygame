class_name IconMarker
extends Node

static func find(node:Node2D) -> IconMarker:
	return Global.iterate_children_until(node, func(n): return n is IconMarker or n is Marker2D)
