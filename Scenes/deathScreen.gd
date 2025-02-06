extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


var player_health = 100
func _health(death):
	if player_health <= 0:
		get_tree().change_scene_to_file("res://deathScreen.gd")
func _display() -> void:
	print("You died loser")

func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://title_screen.tscn")
