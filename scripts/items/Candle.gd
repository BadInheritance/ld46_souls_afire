extends Node2D

export var shorteningRate = 0.3
const CANDLE_LENGTH = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	$Wax.region_rect = Rect2(0, wax_region_y, 32, 22)

onready var shortening_time = 0
onready var wax_region_y = 5
onready var extinguished = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	shortening_time += delta
	if shortening_time > shorteningRate:
		#Recognize burnt down candle
		if wax_region_y >= CANDLE_LENGTH:
			print_debug("Run out of candle!")
		
		#Shorten candle
		shortening_time = 0
		wax_region_y += 1
		$Wax.region_rect = Rect2(0, wax_region_y, 32, 22)
		$Wax.position.y += 1
		$Flame.position.y += 1
