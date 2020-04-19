extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

onready var picking_area = $Area2D
onready var slot = $"Item slot"

var holding = null

func get_object_to_pickup() -> Node2D:
	var areas = picking_area.get_overlapping_areas()
	for area in areas:
		var parent = area.get_parent()
		if parent.is_in_group('pickable'):
			return parent.get_parent()
	return null
	
func try_pickup():
	var to_pick_up = get_object_to_pickup()
	if to_pick_up == null:
		print('Nothing to pickup')
		return
	
	if holding != null:
		print('Already holding another object!')
		return

	print('Picking up:', to_pick_up)
	to_pick_up.get_parent().remove_child(to_pick_up)
	slot.add_child(to_pick_up)
	to_pick_up.position = Vector2.ZERO
	holding = to_pick_up
	return true

func put_down(dest_pos):
	if holding == null:
		print('Nothing to put down')
		return
	
	var my_parent = get_parent()
	holding.get_parent().remove_child(holding)
	# The object to put down is made sibling of the parent
	get_parent().get_parent().add_child(holding)
	holding.position = dest_pos
	
	var ret = holding
	holding = null
	return ret
