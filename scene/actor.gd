class_name Actor
extends CharacterBody2D

# TODO unable to use @onready (see todo in stop_moving method)
@export var nav_agent:NavigationAgent2D # = $NavigationAgent2D
@export var sprite_direction:Node2D # = $SpriteDirection
@export var animation:AnimationPlayer # = $AnimationPlayer

var role = ActorHelper.ACTOR_ROLE.PATRON
var inventory = InventoryHelper.Inventory.new(self)
var move_speed = 50

func stop_moving():
	# TODO all @onready vars are NULL :\
	velocity = Vector2.ZERO
	nav_agent.target_position = global_position

func nav_move():
	## nav movement
	if not nav_agent.is_target_reached() and nav_agent.is_target_reachable():
		var next_pos: Vector2 = nav_agent.get_next_path_position()
		velocity = global_position.direction_to(next_pos) * move_speed

func face_move_direction():
	if velocity != Vector2.ZERO:
		# face left/right
		sprite_direction.scale.x = velocity.sign().x * -1

func _ready():
	add_to_group('actor')

func _physics_process(delta):
	move_and_slide()


func _on_actor_state_machine_change_state(node):
	stop_moving()
