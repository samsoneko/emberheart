extends Node2D

func _on_area_2d_body_entered(body):
	if body == Global.player:
		get_tree().change_scene_to_file("res://world/dungeon/dungeon.tscn")
