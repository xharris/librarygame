class_name Icon
extends Control

static var l = Log.new()

@export var texture_rect:TextureRect
@export var viewport:SubViewport
@export var camera:Camera2D
@export var viewport_container:SubViewportContainer
@export var texture_container:Node2D

func _get_sprites(node:Node2D, sprites:Array[Node2D] = [], parent:Node2D = node) -> Array[Node2D]:
	for child in node.get_children():
		var copy:Node2D
		if child is Sprite2D:
			copy = child.duplicate()
		elif child is AnimatedSprite2D:
			var texture = child.sprite_frames.get_frame_texture(child.animation, child.frame)
			copy = Sprite2D.new()
			copy.texture = texture
		if copy:
			copy.position = parent.to_local(child.global_position)
			l.info('%s %s', [child, child.position])
			sprites.append(copy)
		elif child is Node2D:
			_get_sprites(child, sprites, parent)
	return sprites

func clear_icon():
	for child in texture_container.get_children():
		texture_container.remove_child(child)

func set_icon(node:Node2D):
	clear_icon()
	var marker = IconMarker.find(node)
	if marker:
		texture_container.position = marker.position * -1
		texture_container.scale = marker.scale
	else:
		texture_container.position = Vector2.ZERO
	var sprites = _get_sprites(node)
	for sprite in sprites:
		texture_container.add_child(sprite)
