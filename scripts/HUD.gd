extends MarginContainer

signal candle_die

func _process(_delta):
	if Input.is_action_pressed("debug_show_candle_time_left") && OS.is_debug_build():
		find_node("hud_candle_time_left").visible = !find_node("hud_candle_time_left").visible


func _on_candle_time_left(time_left_seconds):
	find_node("hud_candle_time_left").text = str(time_left_seconds)

func set_candle_time(candle_time):
	find_node("Candle").set_candle_time(candle_time)

func on_level_reset():
	_set_hud_main_text("")
	find_node("Candle").reset_candle()
	find_node("Candle").set_candle_visible(false)
	find_node("Candle").connect("candle_time_left", self, "_on_candle_time_left")


func _on_set_candle_visible(visible):
	find_node("Candle").set_candle_visible(visible)


func on_wall_spell():
	find_node("Candle").consume_wall_spell()


func on_fountain_activation():
	find_node("Candle").reset_candle()


func _fwd_candle_die():
	print("_fwd_candle_die")
	emit_signal("candle_die")


func _set_hud_main_text(text):
	var hud_main_text = find_node("hud_main_text")
	hud_main_text.visible = true
	hud_main_text.bbcode_text = text
