extends Node2D

export var shorteningTimeoutSeconds = 60
export var wallSpellCost = 5.0

signal candle_die


# Called when the node enters the scene tree for the first time.
func _ready():
	waxStartLength = $CandleTop/Wax.region_rect.size.y
	timer.connect("timeout", self, "_on_timeout")

onready var is_burning = true

func _add_to_timer(seconds):
	if timer.time_left > 0:
		var new_timer_time = max(0, min(shorteningTimeoutSeconds, timer.time_left + seconds))
		timer.start(new_timer_time)

func consume_wall_spell():
	var new_timer_time = timer.time_left - wallSpellCost
	if new_timer_time < 0:
		is_burning = false
		$CandleTop/Wax.region_rect.size.y = 0
		$CandleTop/Wax.offset.y = (waxStartLength)
		$CandleTop/Flame.offset.y = (waxStartLength)
		_on_timeout()
	else:
		timer.start(new_timer_time)


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
	if is_burning:
		var shortened_fraction = (shorteningTimeoutSeconds - timer.time_left) / shorteningTimeoutSeconds
		if shortened_fraction < 1.0:
			var newWaxLength = waxStartLength * (1 - shortened_fraction)
			$CandleTop/Wax.region_rect.size.y = newWaxLength
			$CandleTop/Wax.offset.y = (waxStartLength - newWaxLength)
			$CandleTop/Flame.offset.y = (waxStartLength - newWaxLength)
