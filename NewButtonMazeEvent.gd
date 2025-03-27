extends Node3D

@onready var player = $GridMap/CharacterBody3D
@onready var electric_orb_container = $GridMap/ElectricOrbContainer
#signal orb_collected

var collected_orbs = 0
var total_orb_count = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	total_orb_count = electric_orb_container.get_child_count()
	
	player.orb_collected.connect(_on_orb_collected)

func _on_orb_collected():
	collected_orbs += 1
	if collected_orbs >= total_orb_count:
		emit_signal("orb_collected")
		print("You just won!")
