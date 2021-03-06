extends Node2D

onready var current_level_holder = $"Game layer/current_level"
onready var level_reload_timer = $level_reload_timer
onready var hud = $"HUD layer/HUD"
var first_level_loaded = false

export var current_level_index = 0
export (String, FILE, "*.tscn") var level0_path = "res://scenes/level0.tscn"
export (String, FILE, "*.tscn") var level1_path = "res://scenes/level1.tscn"
export (String, FILE, "*.tscn") var level2_path = "res://scenes/level2.tscn"
export (String, FILE, "*.tscn") var level3_path = "res://scenes/level3.tscn"
# export (String, FILE, "*.tscn") var level4_path = "res://scenes/level4.tscn"
export (String, FILE, "*.tscn") var level4_path = "res://scenes/Outro.tscn"
export (String, FILE, "*.tscn") var level5_path = "res://scenes/level5.tscn"
export (String, FILE, "*.tscn") var level6_path = "res://scenes/level6.tscn"
export (String, FILE, "*.tscn") var level7_path = "res://scenes/level7.tscn"
export (String, FILE, "*.tscn") var level8_path = "res://scenes/level8.tscn"
export (String, FILE, "*.tscn") var level9_path = "res://scenes/level9.tscn"
export (String, FILE, "*.tscn") var level10_path = "res://scenes/level10.tscn"
export (String, FILE, "*.tscn") var outro_path = "res://scenes/Outro.tscn"

export var levelReloadTimeSeconds = 1
var current_level = null
var loading_level = false

var levels = [
	level0_path,
	level1_path,
	level2_path,
	level3_path,
	level4_path,
	level5_path,
	level6_path,
	level7_path,
	level8_path,
	level9_path,
	level10_path,
	outro_path
]


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


func on_player_reached_hatch(with_lamp):
	if with_lamp:
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
	var player = level.find_node("player")
	assert(player != null && "make sure there is a player with name 'player' in the scene")
	player.connect("player_die", self, "on_player_death")
	player.connect("player_reached_hatch", self, "on_player_reached_hatch")
	player.connect("on_candle_visible", hud, "_on_set_candle_visible")


func _connect_signals(level):
	_connect_end_game_signals(level)
	var player = level.find_node("player")
	assert(player != null)
	player.connect("cast_wall_spell", hud, "on_wall_spell")
	player.connect("activate_fountain", hud, "on_fountain_activation")

	var camera = player.find_node("camera")
	var candle = $"HUD layer/HUD".find_node("Candle", true, false)
	candle.connect("took_damage", camera, "start_shake")

func load_level_params(level):
	var candle_time = level.get_node("LevelParams").candleTime
	hud.set_candle_time(candle_time)


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
	if level_path == outro_path:
		hud.visible = false
		loading_level = false
		return

	_connect_signals(level)
	var player_camera: Camera2D = level.find_node("player").find_node("camera")
	player_camera.current = true
	hud.on_level_reset()
	print("level loaded")
	load_level_params(level)
	loading_level = false
