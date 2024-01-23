extends Camera2D

var log = Log.new(Log.LEVEL.DEBUG)

var drag_mouse_start:Vector2
var dragging = false
var target_zoom = zoom
var touches = 0
var touch_distance = -1

func is_drag_start(event:InputEvent) -> bool:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE and event.is_pressed():
			return true
	if event is InputEventScreenTouch:
		if event.is_pressed():
			return true
	return false

func is_drag_end(event:InputEvent) -> bool:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE and event.is_released():
			return true
	if event is InputEventScreenTouch:
		if event.is_released():
			return true
	return false

## TODO pinch zoom
func is_zoom_in(event:InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			return true
	return false
	
## TODO pinch zoom
func is_zoom_out(event:InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			return true
	return false

func _input(event):
	# Panning
	if is_drag_start(event):
		dragging = true
		drag_mouse_start = event.position
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if is_drag_end(event):
		dragging = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	if (event is InputEventMouseMotion or event is InputEventScreenDrag) and dragging:
		offset -= event.relative / zoom
		
	# Zooming
	if is_zoom_in(event) and target_zoom < Vector2(3,3):
		target_zoom += Vector2(0.5,0.5)
	if is_zoom_out(event) and target_zoom > Vector2.ONE:
		target_zoom -= Vector2(0.5,0.5)

func _process(delta):
	zoom = zoom.lerp(target_zoom, delta * 5)
