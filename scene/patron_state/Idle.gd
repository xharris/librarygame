extends PatronStateMachine

@export var body: CharacterBody2D
@export var nav_agent: NavigationAgent2D

var r = 0
func pick_new_state():
	print('picked ',r)
	match r:
		0:
			# walk to a random spot
			var random_cell := TileMapHelper.get_random_tilemap_cell()
			if random_cell.is_valid():
				NavigationHelper.toggle_layers(nav_agent, [NavigationHelper.LAYER.NO_IDLE_FLOOR], false)
				nav_agent.target_position = random_cell.map_to_global()
		1:
			# stand still
			body.velocity = Vector2.ZERO
		2:
			# read
			get_parent()\
				.push_state('GetItem', func(item:InventoryHelper.Item): return item.type == InventoryHelper.ITEM_TYPE.BOOK)\
				.push_state('Read')
			
	r = Util.weighted_choice([20, 30, 50])
	
func enter():
	# TODO move_speed = 25
	nav_agent.target_desired_distance = 10
	pick_new_state()
