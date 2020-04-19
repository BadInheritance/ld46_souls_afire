extends Line2D

func _physics_process(delta):
	var raycast: RayCast2D = get_parent()
	self.set_point_position(1, raycast.cast_to)
