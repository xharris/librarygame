extends Node2D

@onready var book_fill := $Item/BookFill

func config(args:Dictionary):
	var color = args.get('color', book_fill.modulate) as Color
	book_fill.modulate = color

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
