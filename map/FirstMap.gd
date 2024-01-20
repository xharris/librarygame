extends Node2D

var scn_patron_task = preload('res://task/patron_task.tscn')

func _on_map_spawn_patron(actor):
	var new_patron_task := scn_patron_task.instantiate() as TaskManager
	var fsm = actor.get_node("ActorStateMachine") as ActorStateMachine
	fsm.add_child(new_patron_task)
	actor.inventory.add_item(InventoryHelper.Item.create_from_id(1))
