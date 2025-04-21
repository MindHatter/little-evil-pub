extends Node2D


@onready var dice_scene = preload("res://scenes/dice.tscn")
@onready var drink_scene = preload("res://scenes/drink.tscn")
@onready var bottom_dices_zone = $BottomDicesZone
@onready var top_dices_zone = $TopDicesZone
@onready var bottom_combo_zone = $BottomComboZone
@onready var top_combo_zone = $TopComboZone
@onready var top_drinks_zone = $TopDrinksZone
@onready var bottom_drinks_zone = $BottomDrinksZone
@onready var timer = $Timer


var bottom_dices_set = []
var top_dices_set = []
var bottom_drinks_set = []
var top_drinks_set = []

var ADDRESS = "127.0.0.1"
var PORT = 5555
var enet_peer = ENetMultiplayerPeer.new()

var hand

var double_call_flag = 0

var combo_map = {
	"7": "Five of a Kind",
	"6": "Four of a Kind",
	"5": "Full House",
	"4": "Straight",
	"3": "Three of a Kind",
	"2": "Two Pair",
	"1": "One Pair",
	"0": "Higher One",
	"-1": "No Dices"
}

var top_dices_names = []
var bottom_dices_names = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#if Global.network_data:
		#ADDRESS = Global.network_data["address"]
		#PORT = int(Global.network_data["port"])
	#
	#print(ADDRESS, " ", PORT)
	var error = enet_peer.create_server(PORT)
	if error != OK:
		
		enet_peer.create_client(ADDRESS, PORT)
		multiplayer.multiplayer_peer = enet_peer
		Global.team = Global.Team.TOP
		top_dices_set = Global.buyed_dices
		top_drinks_set = Global.buyed_drinks
		hand = $TopHand
		multiplayer.connected_to_server.connect(_on_connected_ok)
	else:
		multiplayer.multiplayer_peer = enet_peer
		Global.team = Global.Team.BOTTOM
		Global.phase = Global.PHASE.WAIT
		bottom_dices_set = Global.buyed_dices
		bottom_drinks_set = Global.buyed_drinks
		hand = $BottomHand
	Global.bottom_combo_zone_position = bottom_combo_zone.global_position
	Global.top_combo_zone_position = top_combo_zone.global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$TimerSprite/Time.text = "%d:%02d" % [floor($Timer.time_left / 60), int($Timer.time_left) % 60]
	if multiplayer.get_unique_id() != 1:
		if Global.move_dice != "":
			print("send to move", Global.move_dice)
			rpc_id(1, "move_combo", Global.move_dice)
			Global.move_dice = ""
	#if multiplayer.get_unique_id() == 1:
		#print("process ", Global.round, " ", Global.moving_dices_set)
	if multiplayer.get_unique_id() == 1 and Global.round < 4 and Global.moving_dices_set == [] and Global.phase == Global.PHASE.LOOK:
		print("Update")
		var top_choosed_names = []
		for dice in Global.remote_choosed_dices_list:
			top_choosed_names.append(dice.name)
			var dupled = dice.duplicate()
			print("dupled name ", dupled.name)
			dice.queue_free()
			$TopSpawnContainer.remove_child(dice)
			$TopSpawnContainer.add_child(dupled, true)
		for dice in $TopSpawnContainer.get_children():
			dice.get_node("AnimatedSprite2D").pause()
		for dice in $BottomSpawnContainer.get_children():
			dice.get_node("AnimatedSprite2D").pause()
		rpc_id(Global.client_peer, "update_group", top_choosed_names)
		rpc_id(Global.client_peer, "set_group")
		Global.phase = Global.PHASE.BUILD
		rpc_id(Global.client_peer, "call_timer")
		call_timer()


func _on_connected_ok():
	rpc_id(1, "share_dices", top_dices_set, top_drinks_set)


@rpc("any_peer", "call_remote")
func share_dices(dices_set, drinks_set):
	if multiplayer.get_unique_id() != 1:
		Global.client_peer = multiplayer.get_unique_id()
		bottom_dices_set = dices_set
		bottom_drinks_set = drinks_set
	if multiplayer.get_unique_id() == 1:
		Global.client_peer = multiplayer.get_remote_sender_id()
		top_dices_set = dices_set
		top_drinks_set = drinks_set
		rpc_id(multiplayer.get_remote_sender_id(), "share_dices", bottom_dices_set, bottom_drinks_set)
	print(multiplayer.get_unique_id(), " enemy set ", top_dices_set, top_drinks_set)
	print(multiplayer.get_unique_id(), " buyed set ", bottom_dices_set, bottom_drinks_set)
	start()


func start():
	generate_dices()
	generate_drinks()
	if multiplayer.get_unique_id() == 1:
		rpc_id(Global.client_peer, "set_group")
	hand.visible = true
	hand.reset()
	timer.connect("timeout", start_throw)
	rpc("call_timer")


@rpc("any_peer", "call_remote")
func update_group(top_choosed_names):
	var top_spawn_container = $TopSpawnContainer.get_children()
	print(top_choosed_names)
	print("update group ", " ", top_choosed_names, " ", $TopSpawnContainer.get_children().size())

	for idx in range(top_choosed_names.size()):
		var cursor = top_spawn_container.size() - top_choosed_names.size() + idx
		top_spawn_container[cursor].on_field = true
		print("updated")

@rpc("any_peer", "call_remote")
func move_combo(top_dice_name):
	print("move name ", top_dice_name)
	var top_dices = $TopSpawnContainer.get_children()
	for dice in top_dices:
		print("spawned name ", dice.name)
	for idx in range(top_dices.size()):
		if top_dices[idx].name == top_dice_name and Global.remote_combo_list.size() < 5:
			print("find")
			top_dices[idx].on_field = false
			Global.remote_combo_list.append(top_dices[idx])
			Global.update_combo_zone("TOP", top_dices[idx].sprite_size)
	
	
@rpc("any_peer", "call_remote")
func set_group():
	for idx in range(8):
		$TopSpawnContainer.get_children()[idx].add_to_group("TOP")
		$TopSpawnContainer.get_children()[idx].get_node("AnimatedSprite2D").self_modulate.g = 0.7
		$TopSpawnContainer.get_children()[idx].get_node("AnimatedSprite2D").self_modulate.b = 0.3
		$BottomSpawnContainer.get_children()[idx].add_to_group("BOTTOM")


func generate_drinks():
	generate_drink_side("TOP")
	generate_drink_side("BOTTOM")


func generate_drink_side(side):
	var drink_zone
	var drinks_set
	if side == "BOTTOM":
		drink_zone = bottom_drinks_zone
		drinks_set = bottom_drinks_set
	elif side == "TOP":
		drink_zone = top_drinks_zone
		drinks_set = top_drinks_set
	for idx in range(drinks_set.size()):
		var drink = drink_scene.instantiate()
		drink_zone.add_child(drink)
		drink.get_node("Sprite2D").texture = load("res://assets/art/shop/drinks/" + drinks_set[idx] + ".png")
		drink.drink_name = drinks_set[idx]
		drink.position.x = int(0.6 * drink.sprite_size * idx + 15 * idx)


func generate_dices():
	var dices_count = 8
	var side
	if multiplayer.get_unique_id() == 1:
		for idx in range(dices_count):
			generate_side("BOTTOM", idx)
			generate_side("TOP", idx)

func generate_side(side, idx):
	var dice = dice_scene.instantiate()
	if side == "TOP": 
		dice.get_node("AnimatedSprite2D").animation = top_dices_set[idx]
		$TopSpawnContainer.add_child(dice, true)
		dice.modulate.g = 0.7
		dice.modulate.b = 0.3
		top_dices_names.append(dice.dice_name)
		dice.position.x = top_dices_zone.global_position.x + int(0.6 * dice.sprite_size * idx + dice.sprite_size * idx)
		dice.position.y = top_dices_zone.global_position.y
	if side == "BOTTOM":
		dice.get_node("AnimatedSprite2D").animation = bottom_dices_set[idx]
		$BottomSpawnContainer.add_child(dice, true)
		bottom_dices_names.append(dice.dice_name)
		dice.position.x = bottom_dices_zone.global_position.x + int(0.6 * dice.sprite_size * idx + dice.sprite_size * idx)
		dice.position.y = bottom_dices_zone.global_position.y
	dice.add_to_group(side)
	dice.visible = true
	

@rpc("any_peer", "call_remote")
func call_timer():
	print(multiplayer.get_unique_id(), " call timer")
	Global.round += 1
	$RoundLabel.position = Vector2(50, 50)
	Global.phase = Global.PHASE.BUILD
	Global.local_choosed_dices_list = []
	Global.remote_choosed_dices_list = []
	if Global.round >= 4:
		$RoundLabel.text = "Last choice"
		timer.connect("timeout", final)
		timer.wait_time = 10
	else:
		$RoundLabel.text = "Round: " + str(Global.round)
		hand.visible = true
	timer.start()


@rpc("any_peer", "call_remote")
func update_dices_names(dices_names):
	var zone
	if multiplayer.get_unique_id() != 1:
		zone = bottom_dices_zone.get_children()
	if multiplayer.get_unique_id() == 1:
		zone = top_dices_zone.get_children()
	for idx in range(0, zone.size()):
		zone[idx].dice_name = dices_names[idx]
	#for idx in range(8):
		#print(multiplayer.get_unique_id(), " b idx ", idx, " name ", bottom_dices_zone.get_children()[idx].dice_name)
		#print(multiplayer.get_unique_id(), " t idx ", idx, " name ", top_dices_zone.get_children()[idx].dice_name)


@rpc("any_peer", "call_remote")
func save_remote_choice(dices_names):
	print(multiplayer.get_unique_id(), " remote choice ", dices_names)
	var remote_dices
	if multiplayer.get_unique_id() != 1:
		remote_dices = $BottomSpawnContainer
	if multiplayer.get_unique_id() == 1:
		remote_dices = $TopSpawnContainer
	for dice in remote_dices.get_children():
		for dice_name in dices_names:
			if dice_name == dice.name:
				Global.remote_choosed_dices_list.append(dice)
	print(multiplayer.get_unique_id(), " remote saved ", Global.remote_choosed_dices_list)
	throw()


func start_throw():
	#for idx in range(8):
		#print(multiplayer.get_unique_id(), " bottom ", $BottomSpawnContainer.get_children()[idx].name)
		#print(multiplayer.get_unique_id(), " top ", $TopSpawnContainer.get_children()[idx].name)
	hand.visible = false
	var dices_names = []
	for dice in Global.local_choosed_dices_list:
		#dices_names.append(dice.dice_name)
		dices_names.append(dice.name)
	if multiplayer.get_unique_id() != 1:
		rpc_id(1, "save_remote_choice", dices_names)
	if multiplayer.get_unique_id() == 1:
		rpc_id(Global.client_peer, "save_remote_choice", dices_names)
		


func throw():
	Global.moving_dices_set = Global.local_choosed_dices_list + Global.remote_choosed_dices_list
	if multiplayer.get_unique_id() == 1:
		for idx in range(8):
			if idx < Global.remote_choosed_dices_list.size():
				Global.remote_choosed_dices_list[idx].throw($TopHand)
				Global.remote_choosed_dices_list[idx].set_throw()
			if idx < Global.local_choosed_dices_list.size():
				Global.local_choosed_dices_list[idx].throw(hand)
				Global.local_choosed_dices_list[idx].set_throw()
			await get_tree().create_timer(0.2).timeout
	if multiplayer.get_unique_id() != 1:
		for idx in range(8):
			if idx < Global.local_choosed_dices_list.size():
				Global.local_choosed_dices_list[idx].set_throw()
	#for idx in range(8):
		#if idx < Global.local_choosed_dices_list.size():
			#Global.local_choosed_dices_list[idx].throw(hand)
		#await get_tree().create_timer(0.2).timeout
	Global.phase = Global.PHASE.LOOK


func calc_result():
	print(multiplayer.get_unique_id(), " local_combo_list ", Global.local_combo_list)
	print(multiplayer.get_unique_id(), " remote_combo_list ", Global.remote_combo_list)
	var bottom_dices
	var top_dices
	var bottom_combo_values = []
	var top_combo_values = []
	var bottom_combo
	var top_combo
	
	if multiplayer.get_unique_id() == 1:
		bottom_dices = Global.local_combo_list
		top_dices = Global.remote_combo_list
	elif multiplayer.get_unique_id() != 1:
		bottom_dices = Global.remote_combo_list
		top_dices = Global.local_combo_list
		
	if bottom_dices.size() == 0: bottom_combo = -1
	else:
		for dice in bottom_dices:
			bottom_combo_values.append(dice.get_node("AnimatedSprite2D").frame)
		print("bottom_combo_values ", bottom_combo_values)
		var bottom_counts = count_values(bottom_combo_values)
		print("bottom_counts ", bottom_counts)
		bottom_combo = check_combo(bottom_counts, bottom_combo_values)
		print("Bottom combo ", bottom_combo)
	if top_dices.size() == 0: top_combo = -1
	else:
		for dice in top_dices:
			top_combo_values.append(dice.get_node("AnimatedSprite2D").frame)
		var top_counts = count_values(top_combo_values)
		top_combo = check_combo(top_counts, top_combo_values)
	print("Top combo ", top_combo)

	# Compare combo
	var template = combo_map[str(top_combo)] + " vs " + combo_map[str(bottom_combo)]
	var winlose = $Result/WinLose
	var desc = $Result/Desc
	if bottom_combo > top_combo:
		if multiplayer.get_unique_id() == 1:
			winlose.text = "WIN"
			desc.text = template
			Global.wallet += 300
			Global.reputation = 1
		else:
			winlose.text = "LOSE"
			desc.text = template
			Global.reputation = 0
	elif bottom_combo < top_combo:
		if multiplayer.get_unique_id() == 1:
			winlose.text = "LOSE"
			desc.text = template
			Global.reputation = 0
		else:
			winlose.text = "WIN"
			desc.text = template
			Global.wallet += 300
			Global.reputation = 1
	elif bottom_combo == top_combo:
		winlose.text = "TIE"
		desc.text = template
		Global.wallet += 200
	
	$Result.visible = true
	

func count_values(combo_values):
	var counts = {}
	for value in combo_values:
		counts[value] = counts.get(value, 0) + 1
	var sorted_counts = {}
	var count_keys = counts.keys()
	count_keys.sort_custom(func(a, b): return counts[b] < counts[a])
	for key in count_keys:
		sorted_counts[key] = counts[key]
	#sorted_counts.sort_custom(func(a, b): return counts[b] < counts[a])
	return sorted_counts


func check_combo(sorted_counts, values):
	values.sort()
	var counts = sorted_counts.keys()
	if sorted_counts[counts[0]] == 5:
		return 7  # Five of a Kind
	elif sorted_counts[counts[0]] == 4:
		return 6  # Four of a Kind
	elif sorted_counts.size() > 1 and sorted_counts[counts[0]] == 3 and sorted_counts[counts[1]] == 2:
		return 5  # Full House
	elif values == range(values[0], values[0] + 5):
		return 4  # Straight
	elif sorted_counts[counts[0]] == 3:
		return 3  # Three of a Kind
	elif sorted_counts.size() > 1 and sorted_counts[counts[0]] == 2 and sorted_counts[counts[1]] == 2:
		return 2  # Two Pair
	elif sorted_counts[counts[0]] == 2:
		return 1  # One Pair
	else:
		return 0 # High Value


func final():
	Global.phase = Global.PHASE.FINISH
	if multiplayer.get_unique_id() == 1:
		var dices_names = []
		for dice in Global.local_combo_list:
			dices_names.append(dice.name)
		rpc_id(Global.client_peer, "save_combo", dices_names)
		calc_result()

@rpc("any_peer", "call_remote")
func save_combo(dices_names):
	for dice_name in dices_names:
		for dice in $BottomSpawnContainer.get_children():
			if dice.name == dice_name:
				Global.remote_combo_list.append(dice)
	calc_result()

func _on_button_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
		get_tree().change_scene_to_file("res://scenes/bar.tscn")
