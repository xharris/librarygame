class_name DayNight
extends Node2D

static var l = Log.new()
const DAY_GLOW_INTENSITY = 0.4
const NIGHT_GLOW_INTENSITY = 0.1
const NIGHT_DARKNESS = 0.8
const ENV_EFFECT_CHANGE_SPEED = 0.025

enum PART {SUNRISE,MORNING,AFTERNOON,SUNSET,DUSK,NIGHT,DAWN}
static var _gradient_colors:Array[Array] = [
	[Color.html('#5c8ed7'), Color.html('#e9d982')], # sunrise
	[Color.html('#60a2f0'), Color.html('#90c9f9')], # morning
	[Color.html('#3c82d4'), Color.html('#7dbae9')], # afternoon
	[Color.html('#7d577f'), Color.html('#f0a933')], # sunset
	[Color.html('#363f86'), Color.html('#e6823f')], # dusk
	[Color.html('#0a1120'), Color.html('#143d71')], # night
	[Color.html('#53487e'), Color.html('#c68c81')], # dawn
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

static func get_cycle(cycle_progress:float) -> PART:
	return lerp(0, PART.size(), cycle_progress)

@onready var sun:Sprite2D = $%Sun
@onready var moon:Sprite2D = $%Moon
@onready var path_follow:PathFollow2D = $%PathFollow2D
@onready var background:TextureRect = $%Background
@onready var path_container:Node2D = $%PathContainer
@onready var world_env:WorldEnvironment = $%WorldEnvironment

var _visible_planet:Sprite2D
var part:PART
var _gradient_tex:GradientTexture2D
var _gradient:Gradient

# Called when the node enters the scene tree for the first time.
func _ready():
	_hide_planet(sun)
	_hide_planet(moon)
			
	_gradient = Gradient.new()
	_gradient.colors = [_gradient_colors[0][0], _gradient_colors[0][1]]
	_gradient.offsets = [0, 1]
	
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
		part = floor(manager.cycle_progress * PART.size()) as PART
		var next_part = wrapi(part + 1, 0, PART.size()-1)
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
		# Set texture gradient (background)
		var s = (manager.cycle-1) + manager.cycle_progress
		var top_colors:Array[Color] = []
		top_colors.assign(_gradient_colors.map(func(c:Array):return c[0]))
		var bottom_colors:Array[Color] = []
		bottom_colors.assign(_gradient_colors.map(func(c:Array):return c[1]))
		_gradient.colors = [
			Palette.lerp_colors(top_colors, s),
			Palette.lerp_colors(bottom_colors, s),
		]
		# glow
		var target_glow_intensity:float = DAY_GLOW_INTENSITY if manager.cycle_progress < 0.5 else NIGHT_GLOW_INTENSITY
		world_env.environment.glow_intensity = lerpf(0, target_glow_intensity, half_progress)
		# darkness
		var map := Map.get_current_map() as Map
		if map:
			var target_darkness:float = NIGHT_DARKNESS if manager.cycle_progress > 0.5 else 1.0
			map.modulate = lerp(Color.from_hsv(0,0,1,1), Color.from_hsv(0,0,target_darkness,1), half_progress)
