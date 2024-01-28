extends Node2D

func _on_map_spawn_patron(actor):
	var children = actor.get_children().map(func(c:Node):return c.name)
	actor.inventory.add_item(Item.create_from_id(1))
