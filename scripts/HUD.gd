extends Node2D

signal candle_die

func _fwd_candle_die():
	emit_signal("candle_die")

func _set_hud_main_text(text):
	$hud_main_text.visible = true
	$hud_main_text.text = text
