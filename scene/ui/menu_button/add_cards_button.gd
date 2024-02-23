class_name AddCardsButton
extends Button

static var l = Log.new()

var scn_small_card := preload("res://scene/ui/card/small_card.tscn")
@export var card_container:BoxContainer

func get_cards() -> Array[SmallCard]:
	return []

func _on_card_pressed(input:InputEvent, card:SmallCard):
	pass

func _on_pressed():
	var game_ui = GameUI.get_ui()
	game_ui.clear_cards()
	# add cards
	var cards = get_cards()
	for card in cards:
		card.pressed.connect(_on_card_pressed.bind(card))
		card_container.add_child(card)
	# Setup top neighbor
	if cards.size():
		var last_card = cards.back() as SmallCard
		# focus neighbors
		focus_neighbor_top = last_card.get_path()
		last_card.focus_neighbor_bottom = get_path()
