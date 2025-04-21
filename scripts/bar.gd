extends Node2D

@onready var drinks_shop = $DrinksShop
@onready var dices_shop = $DicesShop

@onready var drinks_counter = $DrinksCounter
@onready var dices_counter = $DicesCounter

var shop_item_art_path = "res://assets/art/shop/"
var dices_path = "res://assets/art/shop/dices/"

@onready var shop_item_scene = preload("res://scenes/shop_item.tscn")

var shop_map = []
var drinks_types
var dices_types

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.reputation == 0:
		$Barmen/Text.text = "Hope 'lose' is not your live mantra."
	elif Global.reputation == 1:
		$Barmen/Text.text = "Won?! Interesting. May be I will learn some " + Global.lang_map[Global.locale] + " for you."
	
	Global.scene = "bar"
	$Wallet/Label.text = str(Global.wallet)
	
	for y in range(0, 2):
		for x in range(0, 3):
			shop_map.append([x, y])
			
	generate_shop()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func generate_shop():
	for category in Global.shop_data.keys():
		var shop_map_copy = shop_map.duplicate()
		for item in Global.shop_data[category]:
			var shop_item = shop_item_scene.instantiate()
			
			var rand_int = randi_range(0, shop_map_copy.size() - 1)
			var place = shop_map_copy.pop_at(rand_int)
			var gap_x = 0
			var gap_y = 0
			if category == "drinks":
				drinks_shop.add_child(shop_item)
				if place[0] > 0: gap_x = 10
				if place[1] > 0: gap_y = 120
			elif category == "dices":
				dices_shop.add_child(shop_item)
				if place[0] > 0: gap_x = 15
				if place[1] > 0: gap_y = 130

			shop_item.item = item
			shop_item.category = category
			shop_item.get_node("Sprite2D").texture = load(gen_item_art_path(category, item))
			shop_item.price = Global.shop_data[category][item]["price"]
			shop_item.update_price()
			shop_item.position.y = shop_item.sprite_size * place[1] + gap_y * place[1]
			shop_item.position.x = shop_item.sprite_size * place[0] + gap_x * place[0] + randi_range(-10, 10)


func update_counter(category, item):
	$Wallet/Label.text = str(Global.wallet)
	var shop_item = shop_item_scene.instantiate()
	if category == "drinks":
		drinks_counter.add_child(shop_item)
		shop_item.get_node("Sprite2D").scale = Vector2(0.3, 0.3)
		shop_item.get_node("CollisionShape2D").scale = Vector2(0.3, 0.3)
		shop_item.position.x = int(0.7 * shop_item.sprite_size * (Global.buyed_drinks.size() - 1))
	elif category == "dices":
		dices_counter.add_child(shop_item)
		shop_item.get_node("Sprite2D").scale = Vector2(0.25, 0.25)
		shop_item.get_node("CollisionShape2D").scale = Vector2(0.25, 0.25)
		shop_item.position.x = int(0.6 * shop_item.sprite_size * (Global.buyed_dices.size() - 1))
	shop_item.get_node("Price").visible = false
	shop_item.input_pickable = false
	shop_item.get_node("Sprite2D").texture = load(gen_item_art_path(category, item))

	if Global.buyed_dices.size() == 8:
		$Ready.visible = true

func gen_item_art_path(category, item):
	return shop_item_art_path + category + "/" + item + ".png"

