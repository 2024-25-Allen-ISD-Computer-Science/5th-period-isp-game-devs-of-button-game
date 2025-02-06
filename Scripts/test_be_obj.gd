extends Node3D

var clampval = 30
var bounceMag = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$RigidBody3D.max_contacts_reported = 1
	$RigidBody3D.contact_monitor = true
	$RigidBody3D.apply_central_impulse(Vector3(randi_range(-2,2),randi_range(-2,2),randi_range(-2,2)))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $RigidBody3D.get_contact_count() > 0:
		var middle_man_force = Vector3($RigidBody3D.linear_velocity.x**bounceMag,$RigidBody3D.linear_velocity.y**bounceMag,$RigidBody3D.linear_velocity.z**bounceMag)
		$RigidBody3D.apply_central_force(middle_man_force)
		$RigidBody3D.linear_velocity.x = clamp($RigidBody3D.linear_velocity.x,-clampval,clampval)
		$RigidBody3D.linear_velocity.y = clamp($RigidBody3D.linear_velocity.y,-clampval,clampval)
		$RigidBody3D.linear_velocity.z = clamp($RigidBody3D.linear_velocity.z,-clampval,clampval)
	
