extends Control

var item : DataItem

signal item_selected(item)

func setup(reference_item):
	item = reference_item
	$Panel/ItemIcon.texture = load(GameData.item_data[item.id].spritePath)
	$Panel/ItemName.text = GameData.item_data[item.id].name
	$Panel/ItemCount.text = "[right]" + str(item.count) + "[/right]"

func _on_button_pressed():
	item_selected.emit(item)
