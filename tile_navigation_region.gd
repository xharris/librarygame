class_name TileNavigationRegion
extends NavigationRegion2D

@export var tile_polygon:Polygon2D

func add(coords:Vector2):
	var add_poly = tile_polygon.duplicate()
	navigation_polygon.add_outline(add_poly.polygon)
	for poly in add_poly.polygons:
		navigation_polygon.add_polygon(poly)
	bake_navigation_polygon()

func remove(coords:Vector2):
	var rem_poly = tile_polygon.duplicate()
	var new_nav_poly = Geometry2D.clip_polygons(navigation_polygon.vertices, rem_poly)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
