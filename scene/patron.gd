class_name Patron
extends CharacterBody2D

@onready var sprite := $Sprite
@onready var animation := $AnimationPlayer
@onready var nav_agent := $NavigationAgent2D

var inventory = InventoryHelper.Inventory.new(self)
var move_speed = 50

func _process(delta):
	# face left/right
	if velocity.x > 0:
		sprite.scale.x = -1 # L
	elif velocity.x < 0:
		sprite.scale.x = 1 # R
	# walk/stop animation
	if velocity != Vector2.ZERO:
		animation.play('walk', -1, 4)
	else:
		animation.stop()

func _physics_process(delta):
	# path done
	if nav_agent.is_target_reached():
		velocity = Vector2.ZERO
	# nav movement
	if not nav_agent.is_target_reached() and nav_agent.is_target_reachable():
		var next_pos: Vector2 = nav_agent.get_next_path_position()
		velocity = global_position.direction_to(next_pos) * move_speed
	
	move_and_slide()
