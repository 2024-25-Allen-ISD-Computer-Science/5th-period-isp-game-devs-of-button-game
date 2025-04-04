extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	await get_tree().create_timer(75).timeout
	if $CharacterBody3D.Dead==false:
		get_tree().change_scene_to_file('res://WorldScenes/ButtonRoom.tscn')
