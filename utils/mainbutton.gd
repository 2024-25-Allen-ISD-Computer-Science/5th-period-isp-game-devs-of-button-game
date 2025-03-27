extends Node3D

@export var Activated := false
@export var ObjSpawnPos := Node3D
var eventsdir := "res://buttonevents/"
var eventarray: Array[String] = []
var timeron = false

var level_scenes = [ #preload all lvl events inside res://buttonevents/lvlevents here!
	"res://buttonevents/lvlevents/test_beLVL.tscn",
]
var object_scenes = [ #preload all obj events inside res://buttonevents/objevents here!
	preload("res://buttonevents/objevents/test_beOBJ.tscn")
]
var typesOfEvents = 2 #change to ammount of different types of events we have, we currently have two (levels and objects)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()

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
		var choice = randi() % typesOfEvents
		if choice == 0: #object spawns
			var random_scene = object_scenes[(randi() % object_scenes.size())]  # gets a random scene from object_scenes
			var obj = random_scene.instantiate() #instantiates/"creates" it
			add_child(obj) #puts it in the actual playable world
			obj.global_position = ObjSpawnPos.global_position # put its in the object spawn position (weird round pedestial)
			await get_tree().create_timer(1.5).timeout
		elif choice == 1: #scene gets picked
			var random_scene = level_scenes[(randi() % level_scenes.size())] 
			get_tree().change_scene_to_file(random_scene)
		print(choice)
		timeron=false
	Activated=false
