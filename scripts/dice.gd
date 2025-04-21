extends RigidBody2D

var sprite_size
var dice_choosed = false

const chars = "abcdefghijklmnopqrstuvwxyz0123456789"
var name_length = 16
var dice_name

const MOVE_THRESHOLD = 2.0
var moving = true
var on_field = false
var prev_pos


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dice_name = ""
	#generate_name()
	var current_animation : String = $AnimatedSprite2D.animation
	var sprite_texture : Texture = $AnimatedSprite2D.sprite_frames.get_frame_texture(current_animation, 0)
	sprite_size = int(sprite_texture.get_size()[0] * $AnimatedSprite2D.scale.x)
	$AnimatedSprite2D.frame = range(0, get_node("AnimatedSprite2D").sprite_frames.get_frame_count("General")).pick_random()


func _process(delta: float) -> void:

	#if self in Global.moving_dices_set:
		#print(position, " ", global_position, linear_velocity.length())
	moving = false
	if (linear_velocity.length() > 0.0 and linear_velocity.length() < MOVE_THRESHOLD):
		sleeping = true
	elif linear_velocity.length() >= MOVE_THRESHOLD:
		moving = true
	if self in Global.moving_dices_set and not moving and Global.phase == Global.PHASE.LOOK:
		print(multiplayer.get_unique_id(), "stopped ", linear_velocity.length())
		$AnimatedSprite2D.pause()
		Global.remove_from_move_list(self)
		moving = false


func generate_name():
	for i in range(name_length):
		dice_name += chars[randi() % chars.length()]


func set_throw():
	on_field = true
	dice_choosed = false
	moving = true
	get_node("AnimatedSprite2D").self_modulate.r = 1.0
	get_node("AnimatedSprite2D").play()


func throw(hand):
	print("before set global ", position, " ", global_position)
	set_global_position(hand.global_position)
	print("after set global ", position, " ", global_position)
	set_rotation(hand.rotation + randf_range(
		-hand.field_polygon.polygon[1][0], hand.field_polygon.polygon[1][0]) / 500)
	print("Dice angle: ", rotation)

	apply_central_force(Vector2(sin(rotation), -cos(rotation)) * 5000)
	print("after impulse ", position, " ", global_position)


func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
		#print(Global.team, " ", is_in_group("TOP"), " ", is_in_group("BOTTOM"))
		if Global.team == Global.Team.TOP and is_in_group("TOP") or Global.team == Global.Team.BOTTOM and is_in_group("BOTTOM"):
			if Global.phase == Global.PHASE.BUILD:
				dice_choosed = not dice_choosed
				if dice_choosed and not on_field:
					get_node("AnimatedSprite2D").self_modulate.r = 0.3
					Global.local_choosed_dices_list.append(self)
				else:
					get_node("AnimatedSprite2D").self_modulate.r = 1.0
					Global.remove_from_choosed_list(self)
				if on_field:
					if multiplayer.get_unique_id() != 1 and Global.local_combo_list.size() < 5:
						on_field = false
						Global.local_combo_list.append(self)
						Global.move_dice = name
					if multiplayer.get_unique_id() == 1 and Global.local_combo_list.size() < 5:
						Global.local_combo_list.append(self)
						Global.update_combo_zone("BOTTOM", sprite_size)


func _on_mouse_shape_entered(shape_idx: int) -> void:
		Input.set_custom_mouse_cursor(Global.cursor_finger)


func _on_mouse_shape_exited(shape_idx: int) -> void:
		Input.set_custom_mouse_cursor(Global.cursor_open)


func _on_body_entered(body: Node) -> void:
	#print("Body entered: ", multiplayer.get_unique_id(), " ", body.name, " ", self.name)
	if body.get_groups() and self.get_groups() and body.get_groups() != self.get_groups():

		var body_frame = body.get_node("AnimatedSprite2D").get_frame()
		var self_frame = self.get_node("AnimatedSprite2D").get_frame()
		print(multiplayer.get_unique_id(), " body ", body_frame, " self ", self_frame)
		if body_frame < self_frame:
			body.destroy()
		elif body_frame > self_frame:
			destroy()


func destroy():
	$CollisionShape2D.visible = false
	$AnimatedSprite2D.play("_Destroy")

func _on_animated_sprite_2d_animation_finished() -> void:
	Global.remove_from_move_list(self)
	visible = false
