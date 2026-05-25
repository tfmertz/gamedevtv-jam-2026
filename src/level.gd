extends Node

@export_dir var waves_folder: String = "res://scene/waves"
@export var wave_spawn_interval: float = 5.0
@export var pre_boss_delay := 10

## Where instantiated waves get parented. Usually your enemies container or the world root.
@export var enemy_container: Node
enum Difficulty { EASY, MEDIUM, HARD }
@export var difficulty: Difficulty = Difficulty.EASY
@export var enemy_spawn_interval: float = 5.0
@export var enemy_scenes : Array[PackedScene]


var ship_scene : PackedScene = preload("res://scene/ship_node.tscn")
var group_scene : PackedScene = preload("res://scene/player_group.tscn")
var boss_scene : PackedScene = preload("res://scene/boss_wave.tscn")
var scrap_scene : PackedScene = preload("res://scene/scrap.tscn")

var screen_size : Vector2i

@onready var enemy_vert_spawn_follow_2d: PathFollow2D = $EnemyVertSpawnPath/VertSpawnFollow2D
@onready var wave_timer: Timer = $WaveTimer
@onready var enemy_spawn_timer: Timer = $EnemySpawnTimer
@onready var difficulty_timer: Timer = $DifficultyTimer
@onready var progress_bar: ProgressBar = $CanvasLayer/CenterContainer/HBoxContainer/ProgressBar
@onready var progress_label: Label = $CanvasLayer/CenterContainer/HBoxContainer/ProgressLabel

var player_fleet
var enemy_spawn_min := 1
var enemy_spawn_max := 1
var _wave_scenes_by_difficulty: Dictionary = {
	Difficulty.EASY: [] as Array[PackedScene],
	Difficulty.MEDIUM: [] as Array[PackedScene],
	Difficulty.HARD: [] as Array[PackedScene],
}
# Shuffle deck we'll pick from, allows us to never pick same wave twice in a row
var _wave_bag: Array[PackedScene] = []
# [min, max] enemies per pressure spawn, per difficulty
var _spawn_counts := {
	Difficulty.EASY:   [1, 2],
	Difficulty.MEDIUM: [2, 4],
	Difficulty.HARD:   [3, 6],
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_load_waves()
	init_level()
	
	wave_timer.wait_time = wave_spawn_interval
	enemy_spawn_timer.wait_time = enemy_spawn_interval
	_apply_difficulty()
	load_first_scrap()

func _process(delta: float) -> void:
	# update progress bar
	progress_bar.value = 1 - (difficulty_timer.time_left / difficulty_timer.wait_time)

func _apply_difficulty() -> void:
	var range = _spawn_counts[difficulty]
	enemy_spawn_min = range[0]
	enemy_spawn_max = range[1]
	# start adds spawn with a delay, offset from wave spawn time
	await get_tree().create_timer(17).timeout
	enemy_spawn_timer.start()

func init_level() -> void:
	if player_fleet != null:
		self.remove_child(player_fleet)
		player_fleet.queue_free()
	player_fleet = group_scene.instantiate()
	add_child(player_fleet)
	player_fleet.spawn_mothership()
	#player_fleet.add_gunship()
	#player_fleet.add_shieldship()
	
	#TODO temporary while testing formation code
	#player_fleet.add_gunship()
	#player_fleet.add_shieldship()
	#player_fleet.add_gunship()
	#player_fleet.add_shieldship()

	screen_size = get_window().size

func _current_wave_pool() -> Array[PackedScene]:
	return _wave_scenes_by_difficulty[difficulty]

func _load_waves() -> void:
	_load_waves_from("%s/easy" % waves_folder, Difficulty.EASY)
	_load_waves_from("%s/medium" % waves_folder, Difficulty.MEDIUM)
	_load_waves_from("%s/hard" % waves_folder, Difficulty.HARD)
	
	if _current_wave_pool().is_empty():
		push_warning("WaveSpawner: no waves found for difficulty %s" % Difficulty.keys()[difficulty])
	else:
		_refill_wave_bag()

func _load_waves_from(folder: String, diff: Difficulty) -> void:
	var file_paths := ResourceLoader.list_directory(folder)
	if file_paths == null:
		push_error("WaveSpawner: cannot open %s" % folder)
		return
	for file_name in file_paths:
		if file_name.ends_with(".tscn") or file_name.ends_with(".scn"):
			var path := "%s/%s" % [folder, file_name]
			var scene := load(path) as PackedScene
			if scene != null:
				_wave_scenes_by_difficulty[diff].append(scene)

func _refill_wave_bag() -> void:
	_wave_bag = _current_wave_pool().duplicate()
	_wave_bag.shuffle()

func _on_wave_timer_timeout() -> void:
	if _current_wave_pool().is_empty():
		return
	if _wave_bag.is_empty():
		_refill_wave_bag()
	var scene = _wave_bag.pop_back()
	var wave := scene.instantiate() as Node2D
	var parent: Node = enemy_container if enemy_container != null else get_tree().current_scene
	parent.add_child(wave)

func _on_enemy_spawn_timer_timeout() -> void:
	var spawn_path
	var enemies_to_spawn = randi_range(enemy_spawn_min, enemy_spawn_max)
	
	#TODO pick from other shapes
	spawn_path = enemy_vert_spawn_follow_2d
	
	for i in range(enemies_to_spawn):
		var enemy_scene = enemy_scenes.pick_random()
		var new_enemy = enemy_scene.instantiate()
		if difficulty > Difficulty.EASY:
			new_enemy.shield_health = 1
		
		# get a random position on the path
		spawn_path.progress_ratio = randf()
		# Use global_position because VertSpawnFollow2D is a child of
		# EnemyVertSpawnPath which is the item to the right
		new_enemy.position = spawn_path.global_position
		
		add_child(new_enemy)
		if new_enemy.has_method("spawn_enemy_small"):
			# more likely to be shit heads
			if randf() < .7:
				new_enemy.spawn_enemy_small()
				new_enemy.set_rand_mode(true)
			else:
				new_enemy.spawn_enemy_big()

func _on_difficulty_timer_timeout() -> void:
	if difficulty == Difficulty.HARD:
		# Turn off other spawners
		wave_timer.stop()
		enemy_spawn_timer.stop()
		difficulty_timer.stop()
		# Hide progress UI
		progress_bar.hide()
		progress_label.hide()

		# wait for enemies to clear
		await get_tree().create_timer(pre_boss_delay).timeout

		# for now go to boss directly, until tom builds out more waves
		var boss := boss_scene.instantiate()
		add_child(boss)
		# wait 4 sec
		GameManager.pause_player_control(4.0)
	else:
		# increase difficulty every 2m
		difficulty += 1
		# TODO(isaac) maybe make waves shorter? longer? idk making slightly shorter
		difficulty_timer.stop()
		wave_timer.stop()
		enemy_spawn_timer.stop()
		
		wave_spawn_interval += 0.5
		wave_timer.wait_time = wave_spawn_interval
		enemy_spawn_interval -= 0.5
		enemy_spawn_timer.wait_time = enemy_spawn_interval
		$DifficultyTimer.wait_time -= 15
		progress_label.text = "Wave %d" % (difficulty + 1)
		_refill_wave_bag()
		
		difficulty_timer.start()
		wave_timer.start()
		enemy_spawn_timer.start()


func _on_timer_timeout() -> void:
	pass # Replace with function body.

func load_first_scrap() -> void:
	var scrap = scrap_scene.instantiate()
	scrap.position = Vector2(1183, 516)
	get_tree().current_scene.add_child(scrap)
