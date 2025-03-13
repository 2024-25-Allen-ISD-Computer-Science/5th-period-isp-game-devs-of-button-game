extends Node

@onready var player = $Player
@onready var electric_orb_container = $ElectricOrbContainer

var collected_orbs = 0
var total_orb_count = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	total_orb_count = electric_orb_container.get_child_count()
	
	player.connect("orb_collected", self, "on_orb_collected")

func on_orb_collected():
	collected_orbs += 1
	if collected_orbs >= total_orb_count:
		print("You just won!")
