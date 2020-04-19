extends Line2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func _physics_process(delta):
	var raycast: RayCast2D = get_parent()
	self.set_point_position(1, raycast.cast_to)
