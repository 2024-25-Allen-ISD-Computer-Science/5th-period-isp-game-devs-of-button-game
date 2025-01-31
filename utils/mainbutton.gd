extends Node3D

@export var Activated := false
@export var ObjSpawnPos := Node3D
var eventsdir := "res://buttonevents/"
var eventarray: Array[String] = []
var timeron = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var buttoneventsdir := DirAccess.open(eventsdir)
	var events := buttoneventsdir.get_files()
	for event in events:
		eventarray.append(eventsdir + event)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if %InteractableD.InteractedWith and timeron==false:
		Activated = true
		%InteractableD.InteractedWith=false
	else:
		Activated = false
	if Activated==true and timeron==false:
		timeron=true
		%BPAnim.play("push")
		var random_scene = eventarray.pick_random()
		print(random_scene)
		if "LVL" in random_scene:
			await get_tree().create_timer(1.0).timeout
			get_tree().change_scene_to_file(random_scene)
		elif "OBJ" in random_scene:
			var obj = load(random_scene).instantiate()
			add_child(obj)
			obj.global_position = ObjSpawnPos.global_position
			await get_tree().create_timer(1.5).timeout
		timeron=false
	Activated=false
