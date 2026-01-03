extends MenuPanel

@export var enable_debug_options : bool = true

func update_ui():
	$MenuPanel/MenuButtons/Team.grab_focus()

func _on_menu_button_pressed(button_name):
	Global.ui_manager.go_to_menu(button_name)
