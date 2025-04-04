extends RigidBody3D

@onready var navAgent = $NavigationAgent3D
@export var min_speed = 10
@export var max_speed = 18
@export var start_pos : Vector3
var seesplayer = false
var roaming = false
var newDir = false
var wishDir : Vector3
var newRoam = false
var player : CharacterBody3D
var player_pos : Vector3
var damageArea = preload("res://utils/DMGArea.tscn")
var ableToAttack = true

func update_target_location(targetLocation):
	navAgent.target_position = targetLocation

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var currentLocation = global_transform.origin
	var nextLocation =navAgent.get_next_path_position()
	var newVelocity = (nextLocation - currentLocation).normalized() * get_move_speed() * (10*delta)
	if seesplayer==true:
		player_pos = player.position
		update_target_location(player_pos)
		$face.look_at(player_pos,Vector3.UP)
		apply_central_force(newVelocity*(4*mass))
	if roaming==true:
		var tween = create_tween()
		tween.tween_property($face, "rotation", -$CollisionShape3D.get_parent().rotation.normalized(),0.1)
	for body in get_colliding_bodies():
		if body.name == 'CharacterBody3D' and ableToAttack==true:
			var obj = damageArea.instantiate() #instantiates/"creates" it
			obj.OneTimeDmg = true
			obj.Damage = 1
			add_child(obj) #puts it in the actual playable world
			obj.global_position = player.global_position # put its in the object spawn position (weird round pedestial)
			ableToAttack=false
			await get_tree().create_timer(2).timeout
			obj.queue_free()


func get_move_speed() -> float:
	if !seesplayer:
		return min_speed * 0.7
	return max_speed if seesplayer else min_speed

func _on_sight_body_entered(body: Node3D) -> void:
	if body.name == 'CharacterBody3D':
		player=body
		seesplayer=true
		roaming=false

func _on_sight_body_exited(body: Node3D) -> void:
	if body.name == 'CharacterBody3D':
		seesplayer=false
		roaming=true


func _on_abletoattack_timeout() -> void:
	ableToAttack=true
