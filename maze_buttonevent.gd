extends Node3D

@onready var player = $Node3D/player_character
@onready var electric_orb_container = $Node3D/ElectricOrb

total_orb_count = electric_orb_container.get_child_count()

var collected_orbs = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	player.connect("orb_collected", self, "on_orb_collected")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_orb_collected():
	collected_orbs += 1
	if collected_robs >= total_orb_count:
		print("You just won")
