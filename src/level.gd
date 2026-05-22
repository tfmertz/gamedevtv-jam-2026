extends Node

@export_dir var waves_folder: String = "res://scene/waves"
@export var spawn_interval: float = 10.0
## Where waves spawn relative to. Usually just off the right edge of the screen.
@export var spawn_anchor: Node2D
## Where instantiated waves get parented. Usually your enemies container or the world root.
@export var enemy_container: Node

var ship_scene : PackedScene = preload("res://scene/ship_node.tscn")
var group_scene : PackedScene = preload("res://scene/player_group.tscn")
var enemy_scene : PackedScene = preload("res://scene/enemy_ship_node.tscn")
var screen_size : Vector2i

@onready var enemy_vert_spawn_follow_2d: PathFollow2D = $EnemyVertSpawnPath/VertSpawnFollow2D
@onready var wave_timer: Timer = $WaveTimer

var player_fleet
var enemy_spawn_min := 1
var enemy_spawn_max := 1
var enemy_spawn_timer: Timer
var difficulty_timer: Timer
var _wave_scenes: Array[PackedScene] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_load_waves()
	init_level()
	
	wave_timer.wait_time = spawn_interval
	

func init_level() -> void:
	if player_fleet != null:
		self.remove_child(player_fleet)
		player_fleet.queue_free()
	player_fleet = group_scene.instantiate()
	add_child(player_fleet)
	player_fleet.spawn_mothership()
	player_fleet.add_gunship()
	player_fleet.add_shieldship()
	
	#TODO temporary while testing formation code
	player_fleet.add_gunship()
	player_fleet.add_shieldship()
	player_fleet.add_gunship()
	player_fleet.add_shieldship()

	screen_size =  get_window().size

func _load_waves() -> void:
	var file_paths := ResourceLoader.list_directory(waves_folder)
	if file_paths == null:
		push_error("WaveSpawner: cannot open %s" % waves_folder)
		return
	for file_name in file_paths:
		# Editor saves .tscn; exports remap to .remap/.scn. Check the imported path.
		if file_name.ends_with(".tscn") or file_name.ends_with(".scn"):
			var path := "%s/%s" % [waves_folder, file_name]
			var scene := load(path) as PackedScene
			if scene != null:
				_wave_scenes.append(scene)
	if _wave_scenes.is_empty():
		push_warning("WaveSpawner: no waves found in %s" % waves_folder)


func _on_wave_timer_timeout() -> void:
	if _wave_scenes.is_empty():
		return
	var scene := _wave_scenes.pick_random() as PackedScene
	var wave := scene.instantiate() as Node2D
	if spawn_anchor != null:
		wave.global_position = spawn_anchor.global_position
	var parent: Node = enemy_container if enemy_container != null else get_tree().current_scene
	parent.add_child(wave)


func _on_enemy_spawn_timer_timeout() -> void:
	var enemies_to_spawn = enemy_spawn_min
	var spawn_path
	if (enemy_spawn_max - enemy_spawn_min) > 0:
		enemies_to_spawn += randi() % (enemy_spawn_max - enemy_spawn_min)
	
	#TODO pick from other shapes
	spawn_path = enemy_vert_spawn_follow_2d
	
	for i in range(enemies_to_spawn):
		var new_enemy = enemy_scene.instantiate()
		spawn_path.progress_ratio = ((float(i) / float(enemies_to_spawn)))
		new_enemy.position = spawn_path.position + Vector2(int(screen_size.x) + 10, int(screen_size.y/2))#Vector2((randi() % int(screen_size.x/2) + int(screen_size.x/2)),randi() % int(screen_size.y)) #Vector2(500, 500) #
		
		add_child(new_enemy)
		new_enemy.spawn_enemy_big()
		#new_enemy.flyto(Vector2(0, new_enemy.position.y))
		new_enemy.set_rand_mode(true) #sets them to random mode

func _on_difficulty_timer_timeout() -> void:
	pass # Replace with function body.


func _on_timer_timeout() -> void:
	pass # Replace with function body.
