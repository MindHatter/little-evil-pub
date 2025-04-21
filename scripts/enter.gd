extends Node2D

@onready var closed = $Closed
@onready var dialog = $Dialog
@onready var portal = $Portal
@onready var camera = $Camera2D

var knock_count
var portal_effect
var portal_blur
var blur_dir
var camera_zoom_k = 0
var effect_zoom_k = 0

var flag_scene = preload("res://scenes/flag.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	knock_count = 0
	blur_dir = 1
	portal_effect = portal.get_node("Effect")
	portal_blur = portal.get_node("Blur")
	
	for idx in range(Global.lang_map.keys().size()):
		var flag = flag_scene.instantiate()
		flag.lang = Global.lang_map.keys()[idx]
		flag.get_node("Sprite2D").texture = load("res://assets/art/flags/" + flag.lang + ".png")
		flag.position.x = flag.get_node("Sprite2D").texture.get_size()[0] + (flag.get_node("Sprite2D").texture.get_size()[0] + 20) * idx
		$Dialog/UI/Langs.add_child(flag)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	portal_effect.rotation = fmod((portal_effect.rotation + 1 * delta), 360)
	
	if portal_blur.modulate.a >= 0.9 or portal_blur.modulate.a <= 0.1: blur_dir *= -1
	portal_blur.modulate.a += blur_dir * delta 
	
	camera.zoom += Vector2(camera_zoom_k, camera_zoom_k) * delta * 0.5
	if camera.zoom >= Vector2(2, 2): 
		camera_zoom_k = 0
		
	portal_effect.scale += Vector2(effect_zoom_k, effect_zoom_k) * delta * 0.5
	if portal_effect.scale >= Vector2(3, 3):
		print(effect_zoom_k)
		effect_zoom_k = 0
		get_tree().change_scene_to_file("res://scenes/bar.tscn")


func _on_door_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
		knock_count += 1
		if knock_count >= 3:
			closed.get_node("Door/CollisionShape2D").disabled = true
			dialog.visible = true
			closed.visible = false


func _on_enter_btn_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
		portal.visible = true
		dialog.visible = false
		camera_zoom_k = 1
		effect_zoom_k = 1


func _on_exit_btn_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
		get_tree().quit()


func _on_door_mouse_shape_entered(shape_idx: int) -> void:
	Input.set_custom_mouse_cursor(Global.cursor_knuckle)


func _on_door_mouse_shape_exited(shape_idx: int) -> void:
	Input.set_custom_mouse_cursor(Global.cursor_open)


func _on_enter_btn_mouse_shape_entered(shape_idx: int) -> void:
	Input.set_custom_mouse_cursor(Global.cursor_finger)


func _on_enter_btn_mouse_shape_exited(shape_idx: int) -> void:
	Input.set_custom_mouse_cursor(Global.cursor_open)
