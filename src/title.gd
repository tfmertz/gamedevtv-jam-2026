extends Node2D

func _on_button_press():
	AudioManager.cross_fade_music(AudioManager._game_player)
	GameManager.load_scene("res://scene/level.tscn")

func _on_retry_press():
	GameManager.load_scene("res://scene/level.tscn")
	if not AudioManager._game_player.playing:
		AudioManager.cross_fade_music(AudioManager._game_player)
