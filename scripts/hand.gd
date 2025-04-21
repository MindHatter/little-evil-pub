extends Node2D

@onready var field_polygon = $Field/Polygon2D

var is_dragging = false
var is_rotatable = false
var is_rangable = false
var is_delayable = false
var drag_offset
var rotation_limit = 1
var mouse_y_dir
var angle = 0
var polygon_limit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Label.global_position = get_global_mouse_position() + Vector2(20, -10)
	$Label.rotation = -rotation
	if is_dragging:
		$Label.text = "Pos: " + str(global_position.x)
		global_position.x = get_viewport().get_mouse_position().x + drag_offset.x
	if is_rotatable:
		$Label.text = "Angle: " + str(rotation)
		var mouse_position = get_viewport().get_mouse_position()
		var direction = mouse_position - global_position
		
		if direction.angle() < -rotation_limit:
			angle = -rotation_limit
		elif direction.angle() > rotation_limit:
			angle = rotation_limit
		else:
			angle = direction.angle()
		print(angle)
		rotation = angle
	if is_rangable:
		$Label.text = "Range: " + str(snapped(field_polygon.polygon[1][0] / 500, 0.001))
		print(field_polygon.polygon[1][0], " ", field_polygon.polygon, " ", mouse_y_dir)
		if mouse_y_dir > 0:
			field_polygon.polygon[1][0] -= 1
			if field_polygon.polygon[1][0] < 30:
				field_polygon.polygon[1][0] = 30
			field_polygon.polygon[2][0] += 1
			if field_polygon.polygon[2][0] > -30:
				field_polygon.polygon[2][0] = -30
		if mouse_y_dir < 0:
			field_polygon.polygon[1][0] += 1
			if field_polygon.polygon[1][0] > polygon_limit:
				field_polygon.polygon[1][0] = polygon_limit
			field_polygon.polygon[2][0] -= 1
			if field_polygon.polygon[2][0] < -polygon_limit:
				field_polygon.polygon[2][0] = -polygon_limit


func _on_hand_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		$Label.visible = true
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_offset = global_position - event.position
			else:
				is_dragging = false
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				is_rotatable = true
			else:
				is_rotatable = false


func _on_hand_mouse_exited() -> void:
	is_rotatable = false
	is_dragging = false
	$Label.visible = false


func _on_field_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseMotion:

		$Label.visible = true
		mouse_y_dir = event.relative.y
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_rangable = true
			else:
				is_rangable = false
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				is_delayable = true
			else:
				is_delayable = false


func _on_field_mouse_exited() -> void:
	is_delayable = false
	is_rangable = false
	$Label.visible = false


func _on_hand_mouse_shape_entered(shape_idx: int) -> void:
	Input.set_custom_mouse_cursor(Global.cursor_finger)


func _on_hand_mouse_shape_exited(shape_idx: int) -> void:
	Input.set_custom_mouse_cursor(Global.cursor_open)


func _on_field_mouse_shape_entered(shape_idx: int) -> void:
	Input.set_custom_mouse_cursor(Global.cursor_finger)


func _on_field_mouse_shape_exited(shape_idx: int) -> void:
	Input.set_custom_mouse_cursor(Global.cursor_open)


func reset():
	polygon_limit = 160
	field_polygon.polygon[1][0] = polygon_limit
	field_polygon.polygon[2][0] = -polygon_limit
