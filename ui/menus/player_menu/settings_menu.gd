extends MenuPanel

func _input(event):
	if event.is_action_pressed("confirm"):
		Global.modify_theme($SettingsPanel/ColorPicker.color)
