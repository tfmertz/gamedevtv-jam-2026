extends Node

var ship_scene : PackedScene = preload("res://scene/ship_node.tscn")
var group_scene : PackedScene = preload("res://scene/player_group.tscn")
var enemy_scene : PackedScene = preload("res://scene/enemy_ship_node.tscn")
var screen_size : Vector2i


@onready var enemy_vert_spawn_follow_2d: PathFollow2D = $EnemyVertSpawnPath/VertSpawnFollow2D

var player_fleet
var enemy_spawn_min := 3
var enemy_spawn_max := 5
var enemy_spawn_timer: Timer
var difficulty_timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_level()


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
	

func game_over() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func shoot() -> void:
	pass


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
		new_enemy.spawn_enemy_small()
		new_enemy.flyto(Vector2(0, new_enemy.position.y))


func _on_difficulty_timer_timeout() -> void:
	pass # Replace with function body.
