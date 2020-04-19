extends Node2D

onready var current_level_holder = $"Game layer/current_level"
onready var level_reload_timer = $level_reload_timer
onready var hud = $"HUD layer/HUD"
var first_level_loaded = false

export(String, FILE, "*.tscn") var level_scene_path = "res://scenes/player_and_enemy.tscn"
export var levelReloadTimeSeconds = 1
var current_level = null

func on_level_reload_timeout():
	_load_level(level_scene_path)

func _ready():
	level_reload_timer.connect("timeout", self, "on_level_reload_timeout")
	on_level_reload_timeout()


func on_player_death():
	hud._set_hud_main_text("You Died :(")
	level_reload_timer.start(levelReloadTimeSeconds)

func on_candle_death():
	hud._set_hud_main_text("No! Candle burnt down :(")
	level_reload_timer.start(levelReloadTimeSeconds)

func _connect_end_game_signals(level):
	var player = level.get_node("player")
	assert(player != null && "make sure there is a player with name 'player' in the scene")
	player.connect("player_die", self, "on_player_death")

func _load_level(level_path):
	var level_scene = load(level_path)
	var level = level_scene.instance() 
	_connect_end_game_signals(level)
	
	# clear current_level_holder's children
	for child in current_level_holder.get_children():
		child.queue_free()
	current_level = level
	current_level_holder.add_child(current_level)

	var player_camera: Camera2D = level.get_node("player").find_node("camera")
	player_camera.current = true
	
