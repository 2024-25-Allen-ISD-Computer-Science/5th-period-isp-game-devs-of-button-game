extends CharacterBody3D

@export var look_sensitivity : float = 0.006
@export var jump_velocity := 6.0
@export var auto_bhop := true
@onready var Cam := %Cam
@onready var HealthGui = %Cam/HUD/Healthbarback/healthbarmain
@onready var HealthGuiOH = %Cam/HUD/Healthbarback/healthbaroverheal
@onready var HealthGUIOH_OGPos = HealthGuiOH.position
@onready var HealthGUIOH_OGSize = HealthGuiOH.size
@onready var HealthGui_OGSize = HealthGui.size
@onready var DS = load("res://Player/DeathScreen.tscn").instantiate()

# ground movement settings (also taken from godot sourcelike sthuff
@export var walk_speed := 7.0
@export var sprint_speed := 8.5
@export var ground_accel := 14.0
@export var ground_decel := 10.0
@export var ground_friction := 6.0
@export var Health := 100.0
@export var MaxHealth := 100.0
@export var Dead := false
@export var DmgAmt := 0.0

#air movement settings taken from godot sourcelike shtuff :) (I really like source movement)
@export var air_cap := 0.85 #can surf steeper ramps if var is higher
@export var air_accel := 800.0
@export var air_move_speed := 500.0


var wish_dir := Vector3.ZERO
const CrouchTranslate = 0.7
const CrouchJumpAdd = CrouchTranslate + 0.9
var is_crouched := false

const MAX_STEP_HEIGHT = 0.5
var _snapped_to_stairs_last_frame := false
var _last_frame_was_on_floor = -INF

#function makes sure Dev doesnt have to specify if the player is sprinting or walking in the physics func (for reasons...)
func get_move_speed() -> float:
	if is_crouched:
		return walk_speed * 0.7
	return sprint_speed if Input.is_action_pressed("Sprint") else walk_speed

func _ready():
	for child in $PlayerModel.find_children("*", "VisualInstance3D"):
		child.set_layer_mask_value(1,false)
		child.set_layer_mask_value(2,true)
	%InteractRC.collide_with_bodies=true

func _unhandled_input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Dead==true:
		return
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * look_sensitivity)
			Cam.rotate_x(-event.relative.y * look_sensitivity)
			Cam.rotation.x = clamp(Cam.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func process(delta):
	pass
	
var _saved_camera_global_pos = null
func _save_camera_pos_for_smoothing():
	if _saved_camera_global_pos == null:
		_saved_camera_global_pos = %CamSmooth.global_position

func _slide_camera_smooth_back_to_origin(delta):
	if _saved_camera_global_pos == null: return
	%CamSmooth.global_position.y = _saved_camera_global_pos.y
	%CamSmooth.position.y = clampf(%CamSmooth.position.y, -CrouchTranslate, CrouchTranslate) # Clamp incase teleported
	var move_amount = max(self.velocity.length() * delta, walk_speed/2 * delta)
	%CamSmooth.position.y = move_toward(%CamSmooth.position.y, 0.0, move_amount)
	_saved_camera_global_pos = %CamSmooth.global_position
	if %CamSmooth.position.y == 0:
		_saved_camera_global_pos = null # Stop smoothing camera

func _push_away_rigid_bodies():
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			var push_dir = -c.get_normal()
			var velocity_diff_in_push_dir = self.velocity.dot(push_dir) - c.get_collider().linear_velocity.dot(push_dir)
			velocity_diff_in_push_dir = max(0.,velocity_diff_in_push_dir)
			const APPROX_MASS_KG = 80.0
			var mass_ratio = min(1., APPROX_MASS_KG/c.get_collider().mass)
			push_dir.y = 0
			var push_force = mass_ratio*5.0
			c.get_collider().apply_impulse(push_dir*velocity_diff_in_push_dir*push_force, c.get_position() - c.get_collider().global_position)

func _snap_down_to_stairs_check() -> void:
	var did_snap := false
	var floor_below : bool = %StairBelowRC3D2.is_colliding() and not is_surface_too_steep(%StairBelowRC3D2.get_collision_normal())
	var was_on_floor_last_frame = Engine.get_physics_frames() - _last_frame_was_on_floor == 1
	if not is_on_floor() and velocity.y <=0 and (was_on_floor_last_frame or _snapped_to_stairs_last_frame) and floor_below:
		var body_test_result = PhysicsTestMotionResult3D.new()
		if _run_body_test_motion(self.global_transform, Vector3(0, -MAX_STEP_HEIGHT, 0), body_test_result):
			_save_camera_pos_for_smoothing()
			var translate_y = body_test_result.get_travel().y
			self.position.y += translate_y
			apply_floor_snap()
			did_snap = true
	_snapped_to_stairs_last_frame = did_snap

func _snap_up_stairs_check(delta) -> bool:
	if not is_on_floor() and not _snapped_to_stairs_last_frame: return false
	# Don't snap stairs if trying to jump, also no need to check for stairs ahead if not moving
	if self.velocity.y > 0 or (self.velocity * Vector3(1,0,1)).length() == 0: return false
	var expected_move_motion = self.velocity * Vector3(1,0,1) * delta
	var step_pos_with_clearance = self.global_transform.translated(expected_move_motion + Vector3(0, MAX_STEP_HEIGHT * 2, 0))
	var down_check_result = KinematicCollision3D.new()
	if (self.test_move(step_pos_with_clearance, Vector3(0,-MAX_STEP_HEIGHT*2,0), down_check_result)
	and (down_check_result.get_collider().is_class("StaticBody3D") or down_check_result.get_collider().is_class("CSGShape3D"))):
		var step_height = ((step_pos_with_clearance.origin + down_check_result.get_travel()) - self.global_position).y
		if step_height > MAX_STEP_HEIGHT or step_height <= 0.01 or (down_check_result.get_position() - self.global_position).y > MAX_STEP_HEIGHT: return false
		%StairAheadRC3D.global_position = down_check_result.get_position() + Vector3(0,MAX_STEP_HEIGHT,0) + expected_move_motion.normalized() * 0.1
		%StairAheadRC3D.force_raycast_update()
		if %StairAheadRC3D.is_colliding() and not is_surface_too_steep(%StairAheadRC3D.get_collision_normal()):
			_save_camera_pos_for_smoothing()
			self.global_position = step_pos_with_clearance.origin + down_check_result.get_travel()
			apply_floor_snap()
			_snapped_to_stairs_last_frame = true
			return true
	return false

@onready var _OriginalCollsionHeight = %CollisionShape3D.shape.size.y
func _handle_crouch(delta) -> void:
	var was_crouched_last_frame = is_crouched
	if Input.is_action_pressed("Crouch"):
		is_crouched=true
	elif is_crouched and not self.test_move(self.transform, Vector3(0,CrouchTranslate,0)):
		is_crouched=false
	
	var TranslateYIfPossible := 0.0
	if was_crouched_last_frame != is_crouched and not is_on_floor() and not _snapped_to_stairs_last_frame:
		TranslateYIfPossible = CrouchJumpAdd if is_crouched else -CrouchJumpAdd
	if TranslateYIfPossible != 0.0:
		var result = KinematicCollision3D.new()
		self.test_move(self.transform, Vector3(0,TranslateYIfPossible,0), result)
		self.position.y += result.get_travel().y
		%Head.position.y -= result.get_travel().y
		%Head.position.y = clampf(%Head.position.y, -CrouchTranslate, 0)
	
	%Head.position.y = move_toward(%Head.position.y, -CrouchTranslate if is_crouched else 0, 7.0 * delta)
	%CollisionShape3D.shape.size.y = _OriginalCollsionHeight - CrouchTranslate if is_crouched else _OriginalCollsionHeight
	%CollisionShape3D.position.y = %CollisionShape3D.shape.size.y/2

#SURFING CODE/ like not allowing the player to go into walls, honestly I don't think we'll use this in our game but better safe than sorry :)))
func clip_velocity(normal: Vector3, overbounce: float, delta: float) -> void:
	#I dont think my explanation will do this code any justice but
	#the effect this code will pull off it that when we back up and off of a wall, it'll cancell out
	#our strafe + gravity, allowing us to surf
	var backoff := self.velocity.dot(normal) * overbounce
	#in godot velocity can be away from the plane while colliding, so without the next code player can get stuck in ceilings
	if backoff >= 0: return
	
	var change := normal * backoff
	self.velocity -= change
	
	#sourcelike recipe stuff up next, dunno why its there dont ask xoxo
	var adjust := self.velocity.dot(normal)
	if adjust < 0.0:
		self.velocity -= normal * adjust

#function makes surfing buttery smooth
func is_surface_too_steep(normal: Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > self.floor_max_angle

#function psuedo moves player character to test if they'd like fall n stuff, and if they do, we do some fancy shtuff
func _run_body_test_motion(from: Transform3D, motion: Vector3, result = null) -> bool:
	if not result: result = PhysicsTestMotionParameters3D.new()
	var params = PhysicsTestMotionParameters3D.new()
	params.from = from
	params.motion = motion
	return PhysicsServer3D.body_test_motion(self.get_rid(),params,result)

func _handle_air_physics(delta) -> void:
	self.velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	
	#classic movement recipe for sourcelike movement
	#source movement is peak 
	var cur_speed_in_wish_dir = self.velocity.dot(wish_dir)
	#max speed cap to move the player depends on movespeed and air cap
	var capped_speed = min((air_move_speed * wish_dir).length(), air_cap)
	#strafing code is next, I honestly think this is just magic code tbh
	var add_speed_till_cap = capped_speed - cur_speed_in_wish_dir
	if add_speed_till_cap > 0:
		var accel_speed = air_accel * air_move_speed * delta
		accel_speed = min(accel_speed, add_speed_till_cap)
		self.velocity += accel_speed * wish_dir
		
	#surfing code lul
	if is_on_wall():
		if is_surface_too_steep(get_wall_normal()):
			self.motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
		else:
			self.motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
		clip_velocity(get_wall_normal(), 1, delta) #allows surf somehow 



func _handle_ground_physics(delta) -> void:
	#gets current speed in the direction player wishes 2 go and dot products it w/ direction & velocity
	#dot product is basically just the relationship between the way the player is heading and their velocity
	var cur_speed_in_wish_dir = self.velocity.dot(wish_dir)
	var add_speed_till_cap = get_move_speed() - cur_speed_in_wish_dir
	if add_speed_till_cap > 0:
		var accel_speed = ground_accel * delta * get_move_speed()
		accel_speed = min(accel_speed, add_speed_till_cap)
		self.velocity += accel_speed * wish_dir
	
	#friction code
	var control = max(self.velocity.length(), ground_decel)
	var fric_drop = control * ground_friction * delta
	var new_speed = max(self.velocity.length() - fric_drop, 0.0)
	if self.velocity.length() > 0:
		new_speed /= self.velocity.length()
	self.velocity *= new_speed

func check_for_dmgzones():
	if DmgAmt!=0.0:
		Health-=DmgAmt

func _physics_process(delta):
	if Dead==true:
		return
	if is_on_floor() or _snapped_to_stairs_last_frame: _last_frame_was_on_floor = Engine.get_physics_frames()
	
	#if check_for_dmgzones()[0]: Health-=check_for_dmgzones()[1]
	#normalizing the inputs ensures that moving vertically isnt faster than moving normally
	var input_dir = Input.get_vector("Left","Right","Forward","Backward").normalized()
	#wish_dir is the direction the player "wishes" to go in, the basis of self.global_transform.basis ensures that-
	#the direction the player wants to move in (by moving their mouse) is the way the character actually moves
	#tldr basis makes movement by North East South and West relative to where the player is looking and not global
	wish_dir = self.global_transform.basis * Vector3(input_dir.x, 0., input_dir.y)
	
	_handle_crouch(delta)
	
	if is_on_floor() or _snapped_to_stairs_last_frame:
		if Input.is_action_just_pressed("Jump") or (auto_bhop and Input.is_action_pressed("Jump")):
			self.velocity.y = jump_velocity
		_handle_ground_physics(delta)
	else:
		_handle_air_physics(delta)
	
	if not _snap_up_stairs_check(delta):
		_push_away_rigid_bodies()
		move_and_slide()
		_snap_down_to_stairs_check()
	check_for_dmgzones()
	_slide_camera_smooth_back_to_origin(delta)
	if Input.is_action_just_pressed("Interact"):
		%InteractRC.force_raycast_update()
		if %InteractRC.is_colliding():
			var test = %InteractRC.get_collider()
			for child in test.get_children():
				if child.name == 'InteractableD':
					child.InteractedWith=true
	#hud stuff lol
	if Health > 0 and Health <=MaxHealth: # checks if health is normal
		HealthGui.size.x = HealthGui_OGSize.x*(Health/MaxHealth) #if so, set size of main health bar (the red one)
		#to a percentage of its full ammount based on what Health is at.
	elif Health <=0:
		Dead = true # pretty self explanatory, if health is less than or equal to 0, player dies
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		var tween = create_tween() # tween to make the player keel over when dead lul
		tween.tween_property(self, "rotation_degrees", Vector3(0,0,60),0.5)
		add_child(DS) # adds death screen into the scene hierarchy 
	elif Health > MaxHealth: #if health is more than Max health I clamp it for now but im planning to add an 
		#overheal state for health where if the player gets like more healthpacks / a special healthpack
		#player gets temporary health that degrades overtime (like tf2...) ((I really like that game))
		Health = clamp(Health,0,MaxHealth*1.5)
		var perc = (Health/MaxHealth)
		var MiddleMan1 = HealthGUIOH_OGSize.x-HealthGui.position.x
		HealthGuiOH.position.x = MiddleMan1*perc
		HealthGuiOH.size.x = HealthGuiOH.position.x+(HealthGUIOH_OGSize.x-HealthGui.position.x)

func _on_dmg_area_body_exited(body: Node3D) -> void:
	DmgAmt=0.0
