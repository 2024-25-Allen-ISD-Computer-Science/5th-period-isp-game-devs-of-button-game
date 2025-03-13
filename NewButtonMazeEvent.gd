extends Node3D

@onready var player = $Node3D/CharacterBody3D
@onready var electric_orb_container = $Node3D/ElectricOrbContainer
signal orb_collected

var collected_orbs = 0
var total_orb_count = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	total_orb_count = electric_orb_container.get_child_count()
	
	player.connect("orb_collected", self, "on_orb_collected")

func on_orb_collected():
	collected_orbs += 1
	if collected_orbs >= total_orb_count:
		emit_signal("orb_collected")
		print("You just won!")
