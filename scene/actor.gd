class_name Actor
extends CharacterBody2D

static var GROUP = 'actors'
static var scn_read = preload("res://task/read.tscn")
static var scn_actor = preload('res://scene/actor.tscn')
static var scn_task_mgr = preload('res://scene/task_manager.tscn')

static var l = Log.new()

enum ACTOR_ROLE {PATRON,STAFF,SERVICE}
enum ACTOR_MOOD {NONE,HAPPY,SAD,ANGRY}

static func build(role:ACTOR_ROLE) -> Actor:
	var actor = scn_actor.instantiate() as Actor
	match role:
		ACTOR_ROLE.PATRON:
			var read_task := scn_read.instantiate() as Read
			actor.add_task(read_task)
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
@export var fsm:StateMachine
@onready var inventory:Inventory = $SpriteTransform/Sprite/Inventory
@onready var label := $Label
@export var navigation:AStarNavigationAgent2D
@export var task_manager:TaskManager

var actor_name:String = 'Mr. Bigglesworth'
var role:ACTOR_ROLE = ACTOR_ROLE.PATRON
var mood:ACTOR_MOOD = ACTOR_MOOD.NONE
var happiness = 100
var move_speed = 50
var inspection:Array[Dictionary] = [
	InspectText.build('actor_name'),
	InspectProgress.build('happiness', 'happiness'),
]

func add_task(task:Task):
	var task_mgr = find_child('TaskManager')
	if not task_mgr:
		return l.warn('%s does not have TaskManager', [self])
	task_mgr.add_child(task)

func random_tile_filter(cell:Vector2i, map:Map):
	var cell_source = map.get_cell_source_id(0, cell)
	var stations = StationHelper.get_all()
	var has_station = stations.any(func(s:Station):return s.map_cell == cell)
	return not has_station and cell_source != Map.TILE_NAME.ENTRANCE and cell_source != Map.TILE_NAME.NO_IDLE

func is_active() -> bool:
	return find_parent('Map') != null

## Returns false if the target is too close
func move_to(target:Vector2, speed:int = 50, _target_distance:int = 1) -> bool:
	l.debug('%s move_to from %s to %s',[self, global_position, target])
	navigation.target_position = target
	move_speed = speed
	return true

func stop_moving():
	navigation.stop()

## Returns true if moving
func nav_move() -> bool:
	velocity = navigation.velocity * move_speed
	return navigation.is_pathing()

func face_move_direction():
	if velocity.x != 0:
		# face left/right
		sprite_transform.scale.x = velocity.sign().x * -1

func start_next_task() -> bool:
	if not is_node_ready():
		return false
	return task_manager.start_next_task()

func _ready():
	add_to_group(GROUP)
	label.text = String.num(get_instance_id()).right(4)
	InspectCard.add_properties(self, inspection)

func _physics_process(_delta):
	if nav_move():
		animation.play('walk')
		face_move_direction()
	move_and_slide()

func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed('select'):
		InspectCard.show_card(self)
