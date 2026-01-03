extends Control
class_name MenuPanel

var is_open : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()

func open():
	update_ui()
	show()
	is_open = true

func close():
	hide()
	is_open = false

func update_ui():
	pass

func ready_to_close():
	return true

func close_layer():
	pass
