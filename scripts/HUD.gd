extends MarginContainer

signal candle_die

func on_level_reset():
	_set_hud_main_text("")
	find_node("Candle").reset_candle()


func _fwd_candle_die():
	emit_signal("candle_die")

func _set_hud_main_text(text):
	var hud_main_text = find_node("hud_main_text")
	hud_main_text.visible = true
	hud_main_text.bbcode_text = text
