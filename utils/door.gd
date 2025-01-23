extends Node3D

var Activated := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if %InteractableD.InteractedWith:
		Activated = true
		%InteractableD.InteractedWith=false
	else:
		Activated = false
	if Activated==true:
		if $RigidBody3D.rotation_degrees[1]==90:
			var tween = create_tween()
			tween.tween_property($RigidBody3D, "rotation_degrees", Vector3(0,0,0),0.5)
		elif $RigidBody3D.rotation_degrees[1]==-90 or $RigidBody3D.rotation_degrees[1]==0:
			var tween = create_tween()
			tween.tween_property($RigidBody3D, "rotation_degrees", Vector3(0,90,0),0.5)
	Activated=false
	
