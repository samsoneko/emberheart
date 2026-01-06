extends MenuPanel

var item_card_resource = preload("res://ui/elements/item_card/item_card.tscn")
@onready var item_tab_buttons = [$ItemsPanel/VBoxContainer/HBoxContainer/AllItemsButton, $ItemsPanel/VBoxContainer/HBoxContainer/ConsumableButton, $ItemsPanel/VBoxContainer/HBoxContainer/MaterialButton, $ItemsPanel/VBoxContainer/HBoxContainer/KeyItemButton]
var selected_item
var item_type_shown

# Called when the node enters the scene tree for the first time.
func _ready():
	$DetailPanel.hide()
	$DetailTitlePanel.hide()
	$ActionPanel.hide()

func update_ui():
	update_items("all")
	update_item_buttons($ItemsPanel/VBoxContainer/HBoxContainer/AllItemsButton)
	$ItemsPanel/VBoxContainer/HBoxContainer/AllItemsButton.grab_focus()

func ready_to_close():
	if selected_item == null:
		return true
	else:
		return false

func close_layer():
	if selected_item != null:
		close_details_panel()

func update_items(item_type):
	item_type_shown = item_type
	for item in $ItemsPanel/VBoxContainer/ScrollContainer/ItemList.get_children():
		item.queue_free()
	for item in PlayerData.items:
		if item_type_shown == "all":
			var item_card = item_card_resource.instantiate()
			item_card.setup(item)
			item_card.item_selected.connect(open_details_panel)
			$ItemsPanel/VBoxContainer/ScrollContainer/ItemList.add_child(item_card)
		elif GameData.item_data[item.id].category == item_type_shown:
			var item_card = item_card_resource.instantiate()
			item_card.setup(item)
			item_card.item_selected.connect(open_details_panel)
			$ItemsPanel/VBoxContainer/ScrollContainer/ItemList.add_child(item_card)
	if selected_item != null && PlayerData.get_item_by_id(selected_item.id) == null:
		close_details_panel()

func close_details_panel():
	$DetailPanel.hide()
	$DetailTitlePanel.hide()
	$ActionPanel.hide()
	#if PlayerData.get_item_by_id(selected_item.item_id) != null:
		#selected_item.grab_focus()
	if item_type_shown == "all":
		$ItemsPanel/VBoxContainer/HBoxContainer/AllItemsButton.grab_focus()
	elif item_type_shown == "Consumable":
		$ItemsPanel/VBoxContainer/HBoxContainer/ConsumableButton.grab_focus()
	elif item_type_shown == "Material":
		$ItemsPanel/VBoxContainer/HBoxContainer/MaterialButton.grab_focus()
	elif item_type_shown == "Key":
		$ItemsPanel/VBoxContainer/HBoxContainer/KeyItemButton.grab_focus()
	selected_item = null
	$ItemsPanel.show()
	$TitlePanel.show()

func update_item_buttons(active_button):
	for button in item_tab_buttons:
		if button != active_button:
			button.button_pressed = false
		else:
			button.button_pressed = true

func open_details_panel(item):
	$DetailPanel.show()
	$DetailTitlePanel.show()
	$ActionPanel.show()
	selected_item = item
	$DetailTitlePanel/Title.text = GameData.item_data[selected_item.id].name + " " + str(PlayerData.get_item_by_id(selected_item.id).count) + "x"
	$DetailPanel/VSplitContainer/HSplitContainer/Control/Sprite.texture = load(GameData.item_data[selected_item.id].spritePath)
	$DetailPanel/VSplitContainer/HSplitContainer/Control2/Category.text = GameData.item_data[selected_item.id].category
	$DetailPanel/VSplitContainer/Control3/Description.text = GameData.item_data[selected_item.id].description
	$ActionPanel/VBoxContainer/UseButton.grab_focus()
	$ItemsPanel.hide()
	$TitlePanel.hide()

func _on_all_items_button_pressed():
	update_items("all")
	update_item_buttons($ItemsPanel/VBoxContainer/HBoxContainer/AllItemsButton)

func _on_consumable_button_pressed():
	update_items("Consumable")
	update_item_buttons($ItemsPanel/VBoxContainer/HBoxContainer/ConsumableButton)

func _on_material_button_pressed():
	update_items("Material")
	update_item_buttons($ItemsPanel/VBoxContainer/HBoxContainer/MaterialButton)

func _on_key_item_button_pressed():
	update_items("Key")
	update_item_buttons($ItemsPanel/VBoxContainer/HBoxContainer/KeyItemButton)

func _on_discard_button_pressed():
	$DetailTitlePanel/Title.text = GameData.item_data[selected_item.id].name + " " + str(PlayerData.get_item_by_id(selected_item.id).count -1) + "x"
	PlayerData.remove_item(selected_item.id)
	update_items(item_type_shown)
