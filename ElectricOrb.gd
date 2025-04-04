extends Node3D

#signal orb_collected
@onready var collider = $Collider	
@onready var player = $CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collider.area_entered.connect(on_area_entered)
	#player.orb_collected.connect(_on_area_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func on_area_entered(area):
	if area.is_in_group("ElectricOrbs"):
		$orbsound.play()
		$Area3D.queue_free()
		emit_signal("orb_collected")
		print("just hit an orb")


func _on_orbsound_finished() -> void:
	queue_free()
