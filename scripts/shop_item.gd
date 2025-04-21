extends Area2D

var item
var category
var sprite_size
var price


func _ready() -> void:
	var sprite_texture = $Sprite2D.texture
	sprite_size = int(sprite_texture.get_size()[0] * $Sprite2D.scale.x)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func update_price():
	$Price/Label.text = str(price)


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
		if Global.wallet >= price:
			Global.wallet -= price
			if category == "drinks" and Global.buyed_drinks.size() < 2:
				Global.buyed_drinks.append(item)
				get_tree().get_root().get_node("Bar").update_counter(category, item)
			elif category == "dices" and Global.buyed_dices.size() < 8:
				Global.buyed_dices.append(item)
				get_tree().get_root().get_node("Bar").update_counter(category, item)


func _on_mouse_shape_entered(shape_idx: int) -> void:
	Input.set_custom_mouse_cursor(Global.cursor_finger)
	var desc = Global.shop_data[category][item]["desc"]
	get_tree().get_root().get_node("Bar/Barmen/Dialog").visible = true
	get_tree().get_root().get_node("Bar/Barmen/Text").text = desc
	get_tree().get_root().get_node("Bar/Barmen/Text").visible = true


func _on_mouse_shape_exited(shape_idx: int) -> void:
	get_tree().get_root().get_node("Bar/Barmen/Dialog").visible = false
	get_tree().get_root().get_node("Bar/Barmen/Text").visible = false
	Input.set_custom_mouse_cursor(Global.cursor_open)
