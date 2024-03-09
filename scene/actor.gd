class_name Actor
extends Node2D

static var GROUP = 'actors'
static var scn_actor = preload('res://scene/actor.tscn')

static var l = Log.new()

enum ROLE {PATRON,STAFF,SERVICE}
enum ACTOR_MOOD {NONE,HAPPY,SAD,ANGRY}

static func build(role:ROLE) -> Actor:
	var actor = scn_actor.instantiate() as Actor
	actor.role = role
	if role == ROLE.PATRON:
		actor.likes_genres = Book.random_genres()
	return actor

static func get_actor_node(node:Node2D) -> Actor:
	return node.find_child('Actor')

static func get_all() -> Array[Actor]:
	var actors:Array[Actor] = []
	actors.assign(Global.get_tree().get_nodes_in_group(GROUP))
	return actors

static func get_at_map_cell(cell:Vector2i) -> Array[Actor]:
	var map := TileMapHelper.get_current_map() as Map
	if not map:
		return []
	return get_all().filter(func(a:Actor):return a.global_position.distance_to(map.map_to_global(cell)) < 3)

@export var sprite_transform:Node2D
@export var animation:AnimationPlayer
@onready var inventory:Inventory = $SpriteTransform/Sprite/Inventory
@export var navigation:AStarNavigationAgent2D
@export var task_manager:TaskManager
@onready var ai:BeehaveTree = $AI

var velocity:Vector2 = Vector2.ZERO
var actor_name:String
var role_name:String
var role:ROLE = ROLE.PATRON:
	set(value):
		role = value
		role_name = ROLE.find_key(role)
var mood:ACTOR_MOOD = ACTOR_MOOD.NONE
var move_speed = 50
var _likes_genres_str = ''
var likes_genres:Array[Book.GENRE] = []:
	set(value):
		likes_genres = value
		_likes_genres_str = ', '.join(likes_genres.map(func(g:Book.GENRE):return Book.GENRE.find_key(g)))
# TODO var dislikes_genres:Array[Book.GENRE] = [] # also update ai/action/find_book
var happiness:int = 100

func move_to(target:Vector2, speed:int = 50, _target_distance:int = 1):
	l.debug('%s move_to from %s to %s',[self, global_position, target])
	navigation.target_position = target
	move_speed = speed
	animation.play('walk')
	#if global_position.distance_to(target) <= _target_distance:
		#stop_moving()

func stop_moving():
	navigation.stop()
	animation.play('stand')

func sit():
	if not is_sitting():
		stop_moving()
		animation.play('sit')

func is_sitting() -> bool:
	return animation.current_animation == 'sit'

func stand():
	stop_moving()
	animation.play('stand')

func despawn():
	Persistent.save_node(self)
	var parent = get_parent()
	if parent:
		parent.remove_child(self)

func is_active() -> bool:
	return find_parent('Map') != null

## Returns true if moving
func nav_move() -> bool:
	velocity = navigation.velocity * move_speed
	return navigation.is_pathing()

func face_move_direction():
	if velocity.x != 0:
		# face left/right
		sprite_transform.scale.x = velocity.sign().x * -1

func move_and_slide(delta):
	position += velocity * delta

func _ready():
	actor_name = NameGenerator.actor_name.call()
	add_to_group(GROUP)

func _process(delta):
	pass
	#var likes_property:InspectPropertyHelper = %Likes
	#if likes_property:
		#if likes_genres.size():
			#likes_property.inspect_show()
		#else:
			#likes_property.inspect_hide()

func _physics_process(delta):
	nav_move()
	face_move_direction()
	move_and_slide(delta)
