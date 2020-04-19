extends Node2D

export var shorteningTimeoutSeconds = 10.0

signal candle_die


# Called when the node enters the scene tree for the first time.
func _ready():
	waxStartLength = $CandleTop/Wax.region_rect.size.y


func _add_to_timer(seconds):
	if timer.time_left > 0:
		var new_timer_time = max(0, min(shorteningTimeoutSeconds, timer.time_left + seconds))
		timer.start(new_timer_time)


onready var timer = $Timer
var waxStartLength


func reset_candle():
	timer.connect("timeout", self, "_on_timeout")
	timer.start(shorteningTimeoutSeconds)
	$CandleTop/Flame.visible = true


func _on_timeout():
	$CandleTop/Flame.visible = false
	emit_signal("candle_die")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var shortened_fraction = (shorteningTimeoutSeconds - timer.time_left) / shorteningTimeoutSeconds

	if shortened_fraction < 1.0:
		var newWaxLength = waxStartLength * (1 - shortened_fraction)
		$CandleTop/Wax.region_rect.size.y = newWaxLength
		$CandleTop/Wax.offset.y = (waxStartLength - newWaxLength)
		$CandleTop/Flame.offset.y = (waxStartLength - newWaxLength)
