extends Node2D

func _on_map_spawn_patron(actor):
	actor.inventory.add_item(Item.create_from_id(1))
