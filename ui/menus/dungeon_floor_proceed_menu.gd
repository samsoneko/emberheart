extends MenuPanel

func update_ui():
	$MainPanel/VBoxContainer/YesButton.grab_focus()

func _on_yes_button_pressed():
	Global.current_scene.proceed_to_next_floor()
	Global.ui_manager.close_ui()

func _on_no_button_pressed():
	Global.ui_manager.close_ui()
