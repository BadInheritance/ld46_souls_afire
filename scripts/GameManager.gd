extends Node2D

onready var current_level = $current_level
onready var level_reload_timer = $level_reload_timer
var first_level_loaded = false

export var levelReloadTimeSeconds = 1

func on_level_reload_timeout():
	_load_level("player_and_enemy.tscn")

func _ready():
	level_reload_timer.connect("timeout", self, "on_level_reload_timeout")

func _set_hud_main_text(text):
	var main_text = current_level.find_node("hud_main_text")
	main_text.visible = true;
	main_text.text = text

func on_player_death():
	_set_hud_main_text("You Died :(")
	level_reload_timer.start(levelReloadTimeSeconds)

func on_candle_death():
	_set_hud_main_text("No! Candle burnt down :(")
	level_reload_timer.start(levelReloadTimeSeconds)

func _connect_end_game_signals(level):
	var player = level.get_node("player")
	assert(player != null && "make sure there is a player with name 'player' in the scene")
	player.connect("player_die", self, "on_player_death")

	var candle = level.find_node("Candle")
	assert(candle != null && "make sure there is a player with name 'Candle' in the scene")
	candle.connect("candle_die", self, "on_candle_death")

func _load_level(level_name):
	var level_scene =	load("res://scenes/" + level_name)
	var level = level_scene.instance() 
	_connect_end_game_signals(level)
	var old_level = current_level
	# old_level.replace_by(level)
	current_level = level
	remove_child(old_level)
	add_child(current_level)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !first_level_loaded:
		_load_level("player_and_enemy.tscn")
		first_level_loaded = true
