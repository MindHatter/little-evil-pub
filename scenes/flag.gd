extends Area2D

var lang

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
		TranslationServer.set_locale(lang)
		Global.locale = lang
		get_tree().get_root().get_node("Enter/Dialog/UI/Label").text = tr("SECURITY_ENTER")
		var enter_btn = get_tree().get_root().get_node("Enter/Dialog/UI/EnterBtn")
		enter_btn.visible = true
		enter_btn.get_node("Label").text = tr("ENTER_THE_PUB")
		var exit_btn = get_tree().get_root().get_node("Enter/Dialog/UI/ExitBtn")
		exit_btn.visible = true
		exit_btn.get_node("Label").text = tr("GO_AWAY")
		get_parent().visible = false


func _on_mouse_shape_entered(shape_idx: int) -> void:
	Input.set_custom_mouse_cursor(Global.cursor_finger)


func _on_mouse_shape_exited(shape_idx: int) -> void:
	Input.set_custom_mouse_cursor(Global.cursor_open)
