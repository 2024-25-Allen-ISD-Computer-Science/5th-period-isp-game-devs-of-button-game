extends Node3D

@export var connect_portal: Area3D 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func _body_entered(body: Node3D) -> void:
	if body.name == "Player":
		var destination = connect_portal.global_transform.origin
		body.global_transform.origin = destination
