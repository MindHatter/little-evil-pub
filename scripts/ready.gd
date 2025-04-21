extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
		if Global.scene == "bar":
			Global.scene == "table"
			get_tree().change_scene_to_file("res://scenes/table.tscn")
		elif Global.scene == "table":
			pass



func _on_mouse_shape_entered(shape_idx: int) -> void:
	Input.set_custom_mouse_cursor(Global.cursor_finger)


func _on_mouse_shape_exited(shape_idx: int) -> void:
	Input.set_custom_mouse_cursor(Global.cursor_open)
