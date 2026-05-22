extends Node2D

func _on_button_press():
	
	GameManager.load_scene("res://scene/level.tscn")
	AudioManager.cross_fade_music(AudioManager.game_music_stream)
