extends Node2D

var SHORTENING_RATE = 0.3
var CANDLE_LENGTH = 20
var shortening_time
var wax_region_y
var extinguished

# Called when the node enters the scene tree for the first time.
func _ready():
	extinguished = false
	shortening_time = 0
	wax_region_y = 5
	$Wax.region_rect = Rect2(0, wax_region_y, 32, 22)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	shortening_time += delta
	if shortening_time > SHORTENING_RATE:
		#Recognize burnt down candle
		if wax_region_y >= CANDLE_LENGTH:
			print_debug("Run out of candle!")
		
		#Shorten candle
		shortening_time = 0
		wax_region_y += 1
		$Wax.region_rect = Rect2(0, wax_region_y, 32, 22)
		$Wax.position.y += 1
		$Flame.position.y += 1
