extends Area3D

@export var Damage := 0.5
var Entered := false

func _on_body_entered(body: Node3D) -> void:
	print("fuck")
	if body.name == 'CharacterBody3D':
		body.DmgAmt=Damage
		print(body.DmgAmt)
