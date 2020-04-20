extends Node2D

export var soundRadius = 100.0
export(Color) var color = Color.white
export var expandTime = 0.3
var emitter = null

var radius setget set_radius, get_radius
var _radius = 0.0
func set_radius(value):
	_radius = value
	if value > 0:
		$Area2D.scale = Vector2(_radius, _radius)
func get_radius():
	return _radius

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.radius = self.radius + soundRadius / expandTime * delta
	if self.radius >= soundRadius:
		self.queue_free()
	self.update()
	
func _draw():
	var width = 0.5 + (soundRadius - self.radius) / soundRadius * 5
	draw_arc(Vector2.ZERO, self.radius, 0, 2*PI, 32, self.color, width, true)


func _on_body_entered(body: Node):
	if emitter == null:
		return
		
	print('body entered:', body)
	if body.is_in_group("enemy"):
		body.look_at(emitter.global_position)

