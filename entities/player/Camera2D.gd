extends Camera2D


func _process(_delta):
	var direction : Vector2 = Input.get_vector("left", "right", "up", "down")
	position += direction * 0.05
