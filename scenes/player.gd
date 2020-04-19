extends KinematicBody2D

export var walkingSpeed = 1.0

onready var sprite = $AnimatedSprite
onready var item_picking = $"Item picking"
var alive = true

signal die

func on_on_hole():
    if alive:
        scale = Vector2(0.1, 0.1)
        alive = false
        emit_signal("die")

func _process(delta):
    if Input.is_action_just_pressed("player_putdown"):
        var item = item_picking.put_down(self.position)
        if item != null:
            return
        
    if Input.is_action_just_pressed("player_action"):
        if item_picking.try_pickup():
            return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
    var deltaSecs = delta * 1000.0
    
    var dirX: float = 0
    var dirY: float = 0
    if Input.is_action_pressed("player_up"):
        dirY = -1
    if Input.is_action_pressed("player_down"):
        dirY = +1
    if Input.is_action_pressed("player_left"):
        dirX = -1
    if Input.is_action_pressed("player_right"):
        dirX = +1
    
    var dir = Vector2(dirX, dirY).normalized()
    move_and_slide(dir * walkingSpeed * deltaSecs)

    if dir == Vector2.ZERO:
        sprite.animation = 'idle'
    else:
        sprite.animation = 'run'
        sprite.flip_h = (dirX < 0)