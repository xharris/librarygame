class_name Actor
extends CharacterBody2D

static var GROUP = 'actor'

static var l = Log.new(Log.LEVEL.DEBUG)

enum ACTOR_ROLE {PATRON,LIBRARIAN,SECURITY,JANITOR}
enum ACTOR_MOOD {NONE,HAPPY,SAD,ANGRY}

static var scn_actor = preload('res://scene/actor.tscn')
static var scn_task_mgr = preload('res://scene/task_manager.tscn')

static func build(tasks:Array[String] = []) -> Actor:
	var actor = scn_actor.instantiate()
	if tasks.size():
		var task_mgr = actor.find_child('TaskManager')
		if task_mgr:
			for task_name in tasks:
				var task = Task.create_by_name(task_name)
				if task:
					task_mgr.add_child(task)
			actor.add_child(task_mgr)
		else:
			l.warn('%s does not have TaskManager', [actor])
	return actor

# TODO unable to use @onready (see todo in stop_moving method)
@export var nav_agent:NavigationAgent2D
@export var sprite_transform:Node2D
@export var animation:AnimationPlayer
@export var fsm:StateMachine
@onready var inventory := $SpriteTransform/Sprite/Inventory
@onready var label := $Label
@export var task_manager:TaskManager

static func get_actor_node(node:Node2D) -> Actor:
	return node.find_child('Actor')

var role:ACTOR_ROLE = ACTOR_ROLE.PATRON
var mood:ACTOR_MOOD = ACTOR_MOOD.NONE
var move_speed = 50

signal navigation_blocked

func is_active() -> bool:
	return find_parent('Map') != null

## Returns false if the target is too close
func move_to(target:Vector2, speed:int = 50, target_distance:int = 15) -> bool:
	nav_agent.target_desired_distance = target_distance
	l.debug('%s move_to from %s to %s',[self, global_position, target])
	move_speed = speed
	nav_agent.target_position = target
	#if not nav_agent.is_target_reachable():
		#nav_agent.target_position = global_position
		#return false
	return true

func stop_moving():
	velocity = Vector2.ZERO
	nav_agent.target_position = global_position

## Returns true if moving
func nav_move() -> bool:
	var next_pos: Vector2 = nav_agent.get_next_path_position()
	var new_velocity = global_position.direction_to(next_pos)
	if not nav_agent.is_target_reached() and not nav_agent.is_target_reachable():
		l.warn('%s Navigation is blocked', [self])
		navigation_blocked.emit()
		stop_moving()
		return false
	if new_velocity == Vector2.ZERO or nav_agent.is_target_reached():
		return false
	velocity = new_velocity * move_speed
	return true

func face_move_direction():
	if velocity != Vector2.ZERO:
		# face left/right
		sprite_transform.scale.x = velocity.sign().x * -1

func start_next_task() -> bool:
	if not is_node_ready():
		return false
	return task_manager.start_next_task()

func _ready():
	add_to_group(GROUP)
	label.text = String.num(get_instance_id()).right(4)

func _physics_process(delta):
	if nav_move():
		animation.play('walk')
		face_move_direction()
	move_and_slide()
