extends Area3D

@export var Damage := 0.5
@export var OneTimeDmg := false
var Entered := false

func _on_body_entered(body: Node3D) -> void:
	if OneTimeDmg==false:
		if body.name == 'CharacterBody3D':
			body.DmgAmt=Damage
			print(body.DmgAmt,'1')
	else:
		if body.name == 'CharacterBody3D':
			if Entered==false:
				body.DmgAmt=Damage
				print(body.DmgAmt,'2')
				await get_tree().create_timer(0.15).timeout
				body.DmgAmt=0
				Entered=true
		
