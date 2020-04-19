extends Node2D

export var shorteningTimeoutSeconds = 5
const candleLength = 20

signal candle_die


# Called when the node enters the scene tree for the first time.
func _ready():
	$Wax.region_rect = Rect2(0, wax_region_y, 32, 22)

onready var shortening_time = 0
onready var wax_region_y = 5
onready var extinguished = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	shortening_time += delta
	if shortening_time > shorteningTimeoutSeconds && ! extinguished:
		#Recognize burnt down candle
		if wax_region_y >= candleLength:
			emit_signal("candle_die")
			extinguished = true
		else:
			shortening_time = 0
			wax_region_y += 1
			$Wax.region_rect = Rect2(0, wax_region_y, 32, 22)
			$Wax.position.y += 1
			$Flame.position.y += 1
