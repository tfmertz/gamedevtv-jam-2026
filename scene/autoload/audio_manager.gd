extends Node
# Autoloads as "AudioManager"

const AGGREGATE_WINDOW := 0.05  # 50ms = 20 sound updates/sec max
const POOL_SIZE := 16 # max audio players

# These sounds are assigned in the Inspector on the audio_manager.tscn scene.
@export var enemy_fire_stream: AudioStream
@export var hit_stream: AudioStream
@export var title_music_stream: AudioStream
@export var game_music_stream: AudioStream
@export var boss_music_stream: AudioStream
@export var player_injured_stream: AudioStream
@export var player_very_injured_stream: AudioStream
@export var boss_laugh_stream: AudioStream
@export var explosion_stream: AudioStream
@export var boss_death_stream: AudioStream

var _enemy_fire_count          := 0
var _bullet_hit_count          := 0
var _player_injured_count      := 0
var _player_very_injured_count := 0
var _explosion_count           := 0
var _boss_laughing             := false
var _boss_dying                := false
var _aggregate_accum           := 0.0
var _pool: Array[AudioStreamPlayer] = []

var _music_player: AudioStreamPlayer
var _game_player: AudioStreamPlayer
var _boss_player: AudioStreamPlayer

var current_player: AudioStreamPlayer

var _music_tween: Tween

var initial_volume := 0.5

func _ready() -> void:
	# Setup background music player
	_music_player = AudioStreamPlayer.new()
	_music_player.stream = title_music_stream
	_music_player.bus = "Music"
	add_child(_music_player)
	_music_player.play()
	current_player = _music_player
	
	_game_player = AudioStreamPlayer.new()
	_game_player.stream = game_music_stream
	_game_player.bus = "Music"
	add_child(_game_player)
	
	_boss_player = AudioStreamPlayer.new()
	_boss_player.stream = boss_music_stream
	_boss_player.bus = "Music"
	add_child(_boss_player)
	
	set_volume(initial_volume)
	#_boss_player.play()
	# Build out our pool of audio stream players to avoid sound conflicts
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_pool.append(p)

func _process(delta: float) -> void:
	_aggregate_accum += delta
	if _aggregate_accum < AGGREGATE_WINDOW:
		return
	_aggregate_accum = 0.0
	if _enemy_fire_count > 0:
		var intensity: float = clampf(_enemy_fire_count / 20.0, 0.0, 1.0)
		_play_pooled(enemy_fire_stream,
			-12.0 + intensity * 8.0,
			randf_range(0.95, 1.05))
		_enemy_fire_count = 0
	if _bullet_hit_count > 0:
		_play_pooled(hit_stream, -10.0, randf_range(0.9, 1.1))
		_bullet_hit_count = 0
	if _player_injured_count > 0:
		_play_pooled(player_injured_stream, 10.0, 1.0)
		_player_injured_count = 0
	if _player_very_injured_count > 0:
		_play_pooled(player_very_injured_stream, 10.0, 1.0)
		_player_very_injured_count = 0
	if _explosion_count > 0:
		var intensity: float = clampf(_explosion_count / 20.0, 0.0, 1.0)
		_play_pooled(explosion_stream,
			-12.0 + intensity * 8.0,
			randf_range(0.95, 1.05))
		_explosion_count = 0
	if _boss_laughing:
		_play_pooled(boss_laugh_stream, 0.0, 1.0)
		_boss_laughing = false
	if _boss_dying:
		_play_pooled(boss_death_stream, 0.0, 1.0)
		_boss_dying = false

func set_volume(volume: float) -> void:
	current_player.volume_linear = volume

func report_enemy_fire() -> void:
	_enemy_fire_count += 1

func report_explosion() -> void:
	_explosion_count += 1

func report_bullet_hit() -> void:
	_bullet_hit_count += 1

func report_player_injured() -> void:
	_player_injured_count += 1

func report_player_very_injured() -> void:
	_player_very_injured_count += 1

func report_boss_laughter() -> void:
	_boss_laughing = true

func report_boss_dying() -> void:
	_boss_dying = true

func cross_fade_music(new_player: AudioStreamPlayer, duration: float = 2.0):
	if _music_tween and _music_tween.is_valid():
		_music_tween.kill()
	new_player.volume_linear = 0.0
	new_player.play()
	_music_tween = create_tween().bind_node(self)
	_music_tween.set_parallel(true)
	_music_tween.tween_property(current_player, "volume_linear", 0.0, duration)
	_music_tween.tween_property(new_player, "volume_linear", 1.0, duration)
	await _music_tween.finished
	if current_player and current_player != new_player:
		current_player.stop()
	current_player = new_player

func _play_pooled(stream: AudioStream, volume_db: float = 0.0,
		pitch: float = 1.0) -> void:
	if stream == null:
		return
	var player := _get_free_player()
	# pool exhausted — audio is dropped
	if player == null:
		return  
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = pitch
	player.play()

func _get_free_player() -> AudioStreamPlayer:
	for p in _pool:
		if not p.playing:
			return p
	return null
