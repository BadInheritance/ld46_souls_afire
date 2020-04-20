extends MarginContainer

export (String, FILE, "*.tscn") var game_manager_path = "res://prefabs/GameManager.tscn"

onready var timer = $SlideTimer
onready var current_slide_index = 0
onready var slides_fadein = [$Slide1/FadeIn, $Slide2/FadeIn, $Slide3/FadeIn, $Slide4/FadeIn, $Slide5/FadeIn]
onready var slides_fadeout = [$Slide1/FadeOut, $Slide2/FadeOut, $Slide3/FadeOut, $Slide4/FadeOut, $Slide5/FadeOut]
onready var intro_done = false

func _ready():
	timer.start()
	slides_fadein[current_slide_index].play("FadeIn")
	yield(slides_fadein[current_slide_index], "animation_finished") 

func _process(delta):
	if not intro_done:
		if timer.is_stopped():
			if  current_slide_index < slides_fadein.size()-1:
				_change_slide()
				timer.start()
#			else:
#				intro_done = true
#				slides_fadeout[current_slide_index].play("FadeOut")
#				yield(slides_fadeout[current_slide_index], "animation_finished") 
#				var game_manager_scene = load(game_manager_path)
#				var game_manager = game_manager_scene.instance()
#				get_parent().add_child(game_manager)
#				queue_free()
		
func _change_slide():
	slides_fadeout[current_slide_index].play("FadeOut")
	yield(slides_fadeout[current_slide_index], "animation_finished") 
	current_slide_index += 1
	slides_fadein[current_slide_index].play("FadeIn")
	yield(slides_fadein[current_slide_index], "animation_finished") 
		
