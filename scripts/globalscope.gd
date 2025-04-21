extends Node

# Global vars
var scene
var cursor_knuckle = load("res://assets/art/UI/UI_cursor_knuckle.png")
var cursor_finger = load("res://assets/art/UI/UI_cursor_finger.png")
var cursor_open = load("res://assets/art/UI/UI_cursor_open.png")
var network_data_path = './data/network.json'
var network_data_file = FileAccess.open(network_data_path, FileAccess.READ)
var network_data

# Bar vars
var buyed_dices = []
var buyed_drinks = []
var wallet = 358
var shop_data_path = "res://data/shop.json"
var shop_data
var shop_data_file = FileAccess.open(shop_data_path, FileAccess.READ)
var reputation = -1
var locale = "en"
var lang_map={
	"en": "English",
	"de": "German",
	"ru": "Russian",
	"it": "Italian",
	"fr": "French"
}

# Table vars
var local_choosed_dices_list = []
var remote_choosed_dices_list = []
var bottom_choosed_dices_list = []
var top_choosed_dices_list = []
var local_combo_list = []
var remote_combo_list = []
var bottom_combo_list = []
var top_combo_list = []
enum Team {TOP, BOTTOM}
enum PHASE {WAIT, BUILD, LOOK, FINISH}
var phase
var round = 0
var moving_dices_set = []
var bottom_combo_zone_position
var top_combo_zone_position
var team
var client_peer
var move_dice = ""

func _ready() -> void:
	shop_data = JSON.parse_string(shop_data_file.get_as_text())
	network_data = JSON.parse_string(network_data_file.get_as_text())
	

func remove_from_choosed_list(dice):
	for idx in range(0, local_choosed_dices_list.size()):
		if local_choosed_dices_list[idx].name == dice.name:
			local_choosed_dices_list.remove_at(idx)
			return

func remove_from_move_list(dice):
	for idx in range(0, moving_dices_set.size()):
		if moving_dices_set[idx].name == dice.name:
			moving_dices_set.remove_at(idx)
			return

func remove_from_combo_list(dice):
	for idx in range(0, local_combo_list.size()):
		if local_combo_list[idx].name == dice.name:
			local_combo_list.remove_at(idx)
			return

func update_combo_zone(side, sprite_size):
	if side == "BOTTOM":
		for idx in range(0, local_combo_list.size()):
			local_combo_list[idx].global_position.x = bottom_combo_zone_position.x
			local_combo_list[idx].global_position.y = bottom_combo_zone_position.y - sprite_size * idx - 100
	elif side == "TOP":
		for idx in range(0, remote_combo_list.size()):
			remote_combo_list[idx].global_position.x = top_combo_zone_position.x
			remote_combo_list[idx].global_position.y = top_combo_zone_position.y - sprite_size * idx - 100

