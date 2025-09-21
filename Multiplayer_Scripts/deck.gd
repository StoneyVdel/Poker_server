extends Node

var card_db_ref
var deck_full = {}
var deck_shuffled = []
var table_ref

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	card_db_ref = preload("res://Multiplayer_Scripts/Card_Database.gd")
	table_ref = $"../GameLogic"
	create_deck()
	shuffle_deck()

func create_deck():
	for i in card_db_ref.Suit:
		for j in card_db_ref.Cards:
			deck_full[j+"_"+i] = []
			deck_full[j+"_"+i].insert(0, card_db_ref.Cards[j])
			deck_full[j+"_"+i].insert(1, card_db_ref.Suit[i])
	
func shuffle_deck():
	randomize()
	deck_shuffled = deck_full.keys()
	deck_shuffled.shuffle()
	print(deck_shuffled)

func draw_card(card_count):
	var drawn_card_names = []
	
	for i in range(card_count):
		if deck_shuffled.size() != 0:
			drawn_card_names.insert(i, deck_shuffled[0])
			deck_shuffled.erase(drawn_card_names[i])
				
	return drawn_card_names

func reformat_cards(hand, user):
	var reform_cards=[]
	var reform_card=[]
	for i in hand.size():
		reform_card.clear()
		reform_card.insert(0, str(deck_full[hand[i]][0]))
		reform_card.insert(1, str(card_db_ref.Suit.find_key(deck_full[hand[i]][1])))
		reform_cards.append(reform_card.duplicate())
		
		if str(user) == "Table":
			table_ref.hand_node.AssignStringArray(reform_card)
			
	return reform_cards
