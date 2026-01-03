extends MenuPanel

var spirit_card_resource = preload("res://ui/elements/spirit_card/spirit_card.tscn")

func update_ui():
	for spirit in $SpiritPanel/ScrollContainer/SpiritList.get_children():
		spirit.queue_free()
	for spirit in PlayerData.spirits:
		var spirit_card = spirit_card_resource.instantiate()
		spirit_card.setup(spirit, SpiritCard.States.LISTITEM)
		$SpiritPanel/ScrollContainer/SpiritList.add_child(spirit_card)
