class_name Actor
extends CharacterBody2D

@onready var sprite := $SpriteDirection
@onready var animation := $AnimationPlayer
@onready var nav_agent := $NavigationAgent2D

var role = ActorHelper.ACTOR_ROLE.PATRON
var inventory = InventoryHelper.Inventory.new(self)
var move_speed = 50

func _ready():
	add_to_group('actor')
	
func _process(delta):
	if velocity != Vector2.ZERO:
		# face left/right
		sprite.scale.x = velocity.sign().x * -1
		animation.play('walk', -1, 4)
	if velocity == Vector2.ZERO and animation.current_animation == 'walk':
		animation.stop()

func _physics_process(delta):
	# path done
	if nav_agent.is_target_reached():
		velocity = Vector2.ZERO
	## nav movement
	if not nav_agent.is_target_reached() and nav_agent.is_target_reachable():
		var next_pos: Vector2 = nav_agent.get_next_path_position()
		velocity = global_position.direction_to(next_pos) * move_speed
	move_and_slide()
