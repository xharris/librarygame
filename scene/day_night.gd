class_name DayNight
extends Node2D

static var l = Log.new()

class DateTime:
	var days:int
	var hours:int
	var minutes:int
	
	func from_game_manager(manager:GameManager):
		days = manager.cycle
		hours = wrapi((manager.cycle_progress * 24) + 6, 0, 24)
		minutes = wrapi(manager.cycle_progress * 24 * 60, 0, 60)
		
	var hours12:int:
		get:
			if hours > 12:
				return hours - 12
			if hours == 0:
				return 12
			return hours
			
	var meridiem:String:
		get:
			return 'AM' if hours < 12 else 'PM'

@onready var sun:Sprite2D = $%Sun
@onready var moon:Sprite2D = $%Moon
@onready var path_follow:PathFollow2D = $Path2D/PathFollow2D

var _visible_planet:Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	_hide_planet(sun)
	_hide_planet(moon)

func _show_planet(planet:Node2D):
	_visible_planet = planet
	planet.visible = true
	
func _hide_planet(planet:Node2D):
	planet.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var camera = get_viewport().get_camera_2d()
	var offset = Vector2.ZERO
	if camera:
		path_follow.h_offset = camera.global_position.x * 0.25
		path_follow.v_offset = camera.global_position.y * 0.25
	position = get_viewport_rect().size / 2 + offset
	var manager = GameManager.get_current()
	if manager and manager.cycle_progress <= 0.5:
		# day time
		_show_planet(sun)
		_hide_planet(moon)
	else:
		# night time
		_show_planet(moon)
		_hide_planet(sun)
	path_follow.progress_ratio = lerpf(0, 1, manager.cycle_progress * 2)
	if _visible_planet:
		# more visible the closer the planet is to the top of the screen (middle of path)
		_visible_planet.modulate.a = lerpf(0, 1, (0.5 - abs(path_follow.progress_ratio - 0.5)) * 2)
