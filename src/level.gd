extends Node

var ship_scene : PackedScene = preload("res://scene/ship_node.tscn")
var group_scene : PackedScene = preload("res://scene/player_group.tscn")
var screen_size = get_window()

var player_fleet

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_level()


func init_level() -> void:
	if player_fleet:
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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func shoot() -> void:
	pass
