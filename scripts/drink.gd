extends Area2D

var sprite_size
var drink_name


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite_size = int($Sprite2D.texture.get_size()[0] * $Sprite2D.scale.x)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_mouse_shape_entered(shape_idx: int) -> void:
	Input.set_custom_mouse_cursor(Global.cursor_finger)


func _on_mouse_shape_exited(shape_idx: int) -> void:
	Input.set_custom_mouse_cursor(Global.cursor_open)


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
		print(drink_name)
		var hand
		if Global.team == Global.Team.TOP:
			hand = get_tree().get_root().get_node("Table/TopHand")
		if Global.team == Global.Team.BOTTOM:
			hand = get_tree().get_root().get_node("Table/BottomHand")
		if drink_name == "Moscow Mule":
			hand.polygon_limit = 240
			hand.get_node("Field/Polygon2D").polygon[1][0] = hand.polygon_limit
			hand.get_node("Field/Polygon2D").polygon[2][0] = -hand.polygon_limit
		queue_free()
