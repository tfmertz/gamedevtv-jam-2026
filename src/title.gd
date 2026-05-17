extends Node2D

func _on_button_press():
	# TODO: tom figure out singleton transitions
	get_tree().root.get_child(0).load_scene("res://scene/level.tscn")
