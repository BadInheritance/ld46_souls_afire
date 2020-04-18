extends Node2D

export var growthRate = 0.1
export var wallDuration = 3
export(String, "Horizontal", "Vertical") var wallDirection = "Horizontal"
const WALL_HEIGHT = 16
var rng
var starting_position
var region_x
var region_y
var region_w

# Called when the node enters the scene tree for the first time.
func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
	if wallDirection == "Vertical":
		region_x = 11
		region_y = 0
		region_w = 5
	elif wallDirection == "Horizontal":
		region_x = 0
		region_y = 0
		region_w = 16
	$WallSprite.region_rect = Rect2(region_x, region_y, region_w, 0)
	starting_position = self.position

onready var is_wall_up = false
onready var elapsed_time = 0
onready var wall_timer = 0
onready var current_wall_height = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_wall_up:
		elapsed_time += delta
		if elapsed_time >= growthRate:
			elapsed_time = 0
			current_wall_height += 1
			$WallSprite.region_rect = Rect2(region_x, region_y, region_w, current_wall_height)
			self.position.x = starting_position.x + rng.randfn(0.0, 0.6)
			if current_wall_height == WALL_HEIGHT:
				self.position.x = starting_position.x
				is_wall_up = true
	else:
		wall_timer += delta
		if wall_timer >= wallDuration-1.5 and wall_timer <= wallDuration-1:
			self.position.x = starting_position.x + rng.randfn(0.0, 0.6)
		elif wall_timer >= wallDuration-1 and wall_timer <= wallDuration:
			self.position.x = starting_position.x
		elif wall_timer >= wallDuration:
			elapsed_time += delta
			if elapsed_time >= growthRate:
				elapsed_time = 0
				current_wall_height -= 1
				$WallSprite.region_rect = Rect2(region_x, region_y, region_w, current_wall_height)
				self.position.x = starting_position.x + rng.randfn(0.0, 0.6)
				if current_wall_height == 0:
					self.remove_and_skip()
