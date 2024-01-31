class_name Actor
extends CharacterBody2D

var l = Log.new()

enum ACTOR_ROLE {PATRON,LIBRARIAN,SECURITY,JANITOR}
enum ACTOR_MOOD {NONE,HAPPY,SAD,ANGRY}

# TODO unable to use @onready (see todo in stop_moving method)
@export var nav_agent:NavigationAgent2D
@export var sprite_transform:Node2D
@export var animation:AnimationPlayer
@export var fsm:ActorStateMachine
@onready var inventory := $Inventory

var role:ACTOR_ROLE = ACTOR_ROLE.PATRON
var mood:ACTOR_MOOD = ACTOR_MOOD.NONE
var move_speed = 50
var _needs_to_stop_moving = false

signal navigation_blocked

## Returns false if the target is too close
func move_to(target:Vector2, speed:int = 50, target_distance:int = 15) -> bool:
	nav_agent.target_desired_distance = target_distance
	l.debug('move_to from %s to %s',[global_position, target])
	move_speed = speed
	nav_agent.target_position = target
	#if not nav_agent.is_target_reachable():
		#nav_agent.target_position = global_position
		#return false
	return true

func stop_moving():
	velocity = Vector2.ZERO
	nav_agent.target_position = global_position
	_needs_to_stop_moving = true

## Returns true if moving
func nav_move() -> bool:
	var next_pos: Vector2 = nav_agent.get_next_path_position()
	var new_velocity = global_position.direction_to(next_pos)
	if not nav_agent.is_target_reached() and not nav_agent.is_target_reachable():
		stop_moving()
		navigation_blocked.emit()
		return false
	if new_velocity == Vector2.ZERO or nav_agent.is_target_reached() or _needs_to_stop_moving:
		_needs_to_stop_moving = false
		return false
	velocity = new_velocity * move_speed
	return true

func face_move_direction():
	if velocity != Vector2.ZERO:
		# face left/right
		sprite_transform.scale.x = velocity.sign().x * -1

func _ready():
	add_to_group('actor')

func _physics_process(delta):
	if nav_move():
		animation.play('walk')
		face_move_direction()
	move_and_slide()


func _on_navigation_agent_2d_path_changed():
	if not nav_agent.is_target_reachable():
		l.warn('Navigation is blocked')
		navigation_blocked.emit()
