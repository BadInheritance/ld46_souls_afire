extends Camera2D

export var shakeDistancePerSec = 10.0

func _process(delta):
	if not $shake_timer.is_stopped():
		var dx = rand_range(0, shakeDistancePerSec)
		var dy = rand_range(0, shakeDistancePerSec)
		self.offset = Vector2(dx, dy) * $shake_timer.time_left
	else:
		self.offset = Vector2.ZERO

func start_shake():
	$shake_timer.start()
	
