extends Node3D

var Activated := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print("balls")
	if %InteractableD.InteractedWith:
		Activated = true
		%InteractableD.InteractedWith=false
	else:
		Activated = false
	if Activated==true:
		%BPAnim.play("push")
	Activated=false
