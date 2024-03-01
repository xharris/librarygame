class_name DayNight
extends Node2D

static var l = Log.new()
const DAY_GLOW_INTENSITY = 0.6
const NIGHT_DARKNESS = 0.8
const ENV_EFFECT_CHANGE_SPEED = 0.1

enum CYCLE {DAWN,SUNRISE,MORNING,AFTERNOON,SUNSET,DUSK,NIGHT}
static var _gradient_colors:Array[Array] = [
	[Color.html('#53487e'), Color.html('#c68c81')], # dawn
	[Color.html('#5c8ed7'), Color.html('#e9d982')], # sunrise
	[Color.html('#60a2f0'), Color.html('#90c9f9')], # morning
	[Color.html('#3c82d4'), Color.html('#7dbae9')], # afternoon
	[Color.html('#7d577f'), Color.html('#f0a933')], # sunset
	[Color.html('#363f86'), Color.html('#e6823f')], # dusk
	[Color.html('#0a1120'), Color.html('#143d71')], # night
]

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

static func get_cycle(cycle_progress:float) -> CYCLE:
	return lerp(0, CYCLE.size(), cycle_progress)

@onready var sun:Sprite2D = $%Sun
@onready var moon:Sprite2D = $%Moon
@onready var path_follow:PathFollow2D = $%PathFollow2D
@onready var background:TextureRect = $%Background
@onready var path_container:Node2D = $%PathContainer
@onready var world_env:WorldEnvironment = $%WorldEnvironment

var _visible_planet:Sprite2D
var glow_cycles = [CYCLE.MORNING]
var dark_cycles = [CYCLE.DUSK, CYCLE.NIGHT]
var cycle:CYCLE
var _gradient_tex:GradientTexture2D
var _gradient_current_colors:Array[Color]
var _gradient:Gradient

# Called when the node enters the scene tree for the first time.
func _ready():
	_hide_planet(sun)
	_hide_planet(moon)
	_gradient = Gradient.new()
	_gradient_current_colors.assign(_gradient_colors[0])
	var offsets = range(0, _gradient_current_colors.size()).map(func(c:float):
		return c/(_gradient_current_colors.size()-1))
	_gradient.colors = _gradient_current_colors
	_gradient.offsets = offsets
	# Create gradient texture
	_gradient_tex = GradientTexture2D.new()
	_gradient_tex.gradient = _gradient
	_gradient_tex.fill_from = Vector2(0, 0)
	_gradient_tex.fill_to = Vector2(0, 1)
	background.texture = _gradient_tex

func _show_planet(planet:Node2D):
	_visible_planet = planet
	planet.visible = true
	
func _hide_planet(planet:Node2D):
	planet.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	path_container.position = get_viewport_rect().size / 2
	var manager = GameManager.get_current()
	if manager:
		var size = _gradient_colors.size() - 1
		cycle = (wrapi(manager.cycle_progress * size, 0, size) + 1) as CYCLE
		# sun/moon
		if manager.cycle_progress <= 0.5:
			# day time
			_show_planet(sun)
			_hide_planet(moon)
		else:
			# night time
			_show_planet(moon)
			_hide_planet(sun)
		path_follow.progress_ratio = lerpf(0, 1, manager.cycle_progress * 2)
		var half_progress = (0.5 - abs(path_follow.progress_ratio - 0.5)) * 2
		if _visible_planet:
			# more visible the closer the planet is to the top of the screen (middle of path)
			_visible_planet.modulate.a = lerpf(0, 1, half_progress)
		# background color 
		# colors from https://celcliptipsprod.s3-ap-northeast-1.amazonaws.com/tips_article_body/ce5d/855122/fe9b468e7276b6d7ea73f93a8f74fca1

		# Set texture gradient
		for c in _gradient_current_colors.size():
			var prev_color = _gradient_current_colors[c]
			var next_color = _gradient_colors[cycle][c]
			_gradient_current_colors[c] = lerp(prev_color, next_color, delta)
		_gradient.colors = _gradient_current_colors
		# glow
		world_env.environment.glow_intensity = lerpf(
			world_env.environment.glow_intensity, DAY_GLOW_INTENSITY if cycle in glow_cycles else 0, delta*ENV_EFFECT_CHANGE_SPEED)
		# darkness
		var map := Map.get_current_map() as Map
		if map:
			map.modulate = map.modulate.lerp(
				Color.from_hsv(0,0,NIGHT_DARKNESS,1) if cycle in dark_cycles else Color.from_hsv(0,0,1,1), 
				delta*ENV_EFFECT_CHANGE_SPEED)
		
