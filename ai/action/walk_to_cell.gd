extends BTAction

var astar:AStarNavigationAgent2D
var map:Map

func _ready():
	astar = Global.find_parent_by_type(self, AStarNavigationAgent2D)
	map = Map.get_current_map()

func tick(actor:Node2D, data:Dictionary):
	var target := data.get('walk_to_cell_target') as Vector2
	if not (astar and map):
		return STATUS.FAILURE
