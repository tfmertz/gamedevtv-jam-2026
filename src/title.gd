extends Node2D

@export var play_won_music := false

func _ready() -> void:
	if play_won_music:
		_play_game_won_music()

func _on_button_press():
	AudioManager.cross_fade_music(AudioManager._game_player)
	GameManager.load_scene("res://scene/level.tscn")

func _on_retry_press():
	GameManager.load_scene("res://scene/level.tscn")
	if not AudioManager._game_player.playing:
		AudioManager.cross_fade_music(AudioManager._game_player)

func _play_game_won_music():
	AudioManager.play_music(AudioManager.game_won_stream)
