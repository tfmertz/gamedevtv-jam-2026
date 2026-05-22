extends Node
# Autoloads as "AudioManager"

const AGGREGATE_WINDOW := 0.05  # 50ms = 20 sound updates/sec max
const POOL_SIZE := 16 # max audio players

# These sounds are assigned in the Inspector on the audio_manager.tscn scene.
@export var enemy_fire_stream: AudioStream
@export var hit_stream: AudioStream
@export var title_music_stream: AudioStream
@export var game_music_stream: AudioStream

var _enemy_fire_count := 0
var _bullet_hit_count := 0
var _aggregate_accum := 0.0
var _pool: Array[AudioStreamPlayer] = []

var _music_player: AudioStreamPlayer

func _ready() -> void:
	# Setup background music player
	_music_player = AudioStreamPlayer.new()
	_music_player.stream = title_music_stream
	_music_player.bus = "Music"
	add_child(_music_player)
	_music_player.play()
	
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

func report_enemy_fire() -> void:
	_enemy_fire_count += 1

func report_bullet_hit() -> void:
	_bullet_hit_count += 1

# TODO(tom) add music cross fade on scene transition
func cross_fade_music(new_stream: AudioStream):
	_music_player.stream = new_stream
	_music_player.play()

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
