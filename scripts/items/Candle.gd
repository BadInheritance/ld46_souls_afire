extends Node2D

var shorteningTimeoutSeconds = 60
export var wallSpellCost = 5.0

signal candle_die
signal candle_time_left(time_left)
signal took_damage

# Called when the node enters the scene tree for the first time.
func _ready():
	waxStartLength = $CandleTop/Wax.region_rect.size.y
	timer.connect("timeout", self, "_on_timeout")

onready var is_burning = true

func set_candle_time(candle_time):
	shorteningTimeoutSeconds = candle_time
	timer.start(shorteningTimeoutSeconds)

func _add_to_timer(seconds):
	if timer.time_left > 0:
		var new_timer_time = max(0, min(shorteningTimeoutSeconds, timer.time_left + seconds))
		timer.start(new_timer_time)

func consume_wall_spell():
	_take_damage(wallSpellCost)

func _take_damage(time_lost):
	var new_timer_time = timer.time_left - time_lost
	if new_timer_time < 0:
		is_burning = false
		$CandleTop/Wax.region_rect.size.y = 0
		$CandleTop/Wax.offset.y = (waxStartLength)
		$CandleTop/Flame.offset.y = (waxStartLength)
		_on_timeout()
	else:
		timer.start(new_timer_time)
		emit_signal("took_damage")


onready var timer = $Timer
var waxStartLength

func set_candle_visible(visible):
	self.visible = visible


func reset_candle():
	timer.start(shorteningTimeoutSeconds)
	$CandleTop/Flame.visible = true
	is_burning = true


func _on_timeout():
	$CandleTop/Flame.visible = false
	emit_signal("candle_die")


func _process(_delta):
	emit_signal("candle_time_left", timer.time_left)

	if Input.is_action_pressed("debug_pause_candle") && OS.is_debug_build():
		timer.paused = !timer.paused

	if is_burning:
		var shortened_fraction = (shorteningTimeoutSeconds - timer.time_left) / shorteningTimeoutSeconds
		if shortened_fraction < 1.0:
			var newWaxLength = waxStartLength * (1 - shortened_fraction)
			$CandleTop/Wax.region_rect.size.y = newWaxLength
			$CandleTop/Wax.offset.y = (waxStartLength - newWaxLength)
			$CandleTop/Flame.offset.y = (waxStartLength - newWaxLength)

func hurt_by_enemy(time_lost):
	_take_damage(time_lost)
