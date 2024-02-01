extends Node2D

@onready var book_fill:Sprite2D = $Item/BookFill
var color:Color = Palette.Blue500

func config(args:Dictionary):
	color = args.get('color', color) as Color

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	book_fill.modulate = book_fill.modulate.lerp(color, delta * 5)
