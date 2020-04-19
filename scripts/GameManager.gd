extends Node2D

onready var current_level_holder = $"Game layer/current_level"
onready var level_reload_timer = $level_reload_timer
onready var hud = $"HUD layer/HUD"
var first_level_loaded = false

export (String, FILE, "*.tscn") var level_scene_path = "res://scenes/player_and_enemy.tscn"
export (String, FILE, "*.tscn") var level1_path = "res://scenes/level1.tscn"
export var levelReloadTimeSeconds = 1
var current_level = null
var current_level_index = 0
var loading_level = false

var levels = [level_scene_path, level1_path]


func get_current_level():
	return levels[current_level_index]


func new_level_available():
	return current_level_index < len(levels)


func on_level_reload_timeout():
	_load_level(get_current_level())


func _is_about_to_reload_scene():
	return loading_level


func _ready():
	level_reload_timer.connect("timeout", self, "on_level_reload_timeout")
	hud.connect("candle_die", self, "on_candle_death")
	on_level_reload_timeout()


func start_level_load_timer():
	loading_level = true
	level_reload_timer.start(levelReloadTimeSeconds)


func on_level_completed():
	if new_level_available():
		hud._set_hud_main_text("[center] Level Completed! [/center]")
		current_level_index += 1
	else:
		hud._set_hud_main_text("[center] Game Completed! [/center]")
		current_level_index = 0
	start_level_load_timer()


func on_player_reached_hatch():
	if ! _is_about_to_reload_scene():
		print("on level completed")
		on_level_completed()


func on_player_death():
	if ! _is_about_to_reload_scene():
		hud._set_hud_main_text("[center] You Died :( [/center]")
		start_level_load_timer()


func on_candle_death():
	var lamp = current_level.find_node("Lamp", true, false)
	assert(lamp != null && "make sure there is 'Lamp' in the scene")
	lamp._on_candle_die()
	if ! _is_about_to_reload_scene():
		hud._set_hud_main_text("[center] No! Candle burnt down :( [/center]")
		start_level_load_timer()


func _connect_end_game_signals(level):
	var player = level.get_node("player")
	assert(player != null && "make sure there is a player with name 'player' in the scene")
	player.connect("player_die", self, "on_player_death")
	player.connect("player_reached_hatch", self, "on_player_reached_hatch")
	player.connect("on_candle_visible", hud, "_on_set_candle_visible")


func _connect_signals(level):
	_connect_end_game_signals(level)
	var player = level.get_node("player")
	assert(player != null)
	player.connect("cast_wall_spell", hud, "on_wall_spell")


func _load_level(level_path):
	var level_scene = load(level_path)
	var level = level_scene.instance()

	# clear current_level_holder's children
	for child in current_level_holder.get_children():
		child.queue_free()
	if current_level != null:
		current_level_holder.remove_child(current_level)
	current_level = level
	current_level_holder.add_child(current_level)

	_connect_signals(level)
	var player_camera: Camera2D = level.get_node("player").find_node("camera")
	player_camera.current = true
	hud.on_level_reset()
	print("level loaded")
	loading_level = false
