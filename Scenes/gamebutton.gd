extends StaticBody3D
@onready var button_anim = $"Button animation player"

func _input(event):
	if event.is_action_pressed("press_button"):
		button_anim.play("pressdown")
		print("Pressed")
	
	if event.is_action_released("press_button"):
		button_anim.play("pressup")
		print("Released")
