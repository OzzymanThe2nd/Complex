extends CharacterBody3D
@export var resetinven : bool
@export var passive_glow : bool
@onready var maingame = self.get_parent_node_3d()
@export var current_weapon : Node3D
var trying_uncrouch : bool = false
var stored_level
var stored_coord
var deagle_load = preload("res://Scenes/Guns/player_deagle.tscn")
var rifle_load = preload("res://Scenes/Guns/player_ak.tscn")
var shotgun_load = preload("res://Scenes/Guns/player_shotgun.tscn")
var stepqueued : bool = false
var footstep_val : float = 6
var step_sound_type = "concrete"
@export var instant_cam_snap : bool = false
@export var cam_locked : bool = false
@export var cam_pan : Vector3 = Vector3(0, 0, 0)
@export var move_locked : bool = false
var pause_possible : bool = true
@export var move_spot : Vector3 = Vector3(0, 0, 0)
var rumble_x_start : float
var rumble_y_start : float
var rumble_x_destination : float
var rumble_y_destination : float
@export var rumbling : bool = false
var footstep_sounds_concrete = ["res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepNormal/FootstepNormal1.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepNormal/FootstepNormal2.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepNormal/FootstepNormal3.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepNormal/FootstepNormal4.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepNormal/FootstepNormal5.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepNormal/FootstepNormal6.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepNormal/FootstepNormal7.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepNormal/FootstepNormal8.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepNormal/FootstepNormal9.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepNormal/FootstepNormal10.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepNormal/FootstepNormal11.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepNormal/FootstepNormal12.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepNormal/FootstepNormal13.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepNormal/FootstepNormal14.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepNormal/FootstepNormal15.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepNormal/FootstepNormal16.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepNormal/FootstepNormal17.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepNormal/FootstepNormal18.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepNormal/FootstepNormal19.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepNormal/FootstepNormal20.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepNormal/FootstepNormal21.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepNormal/FootstepNormal22.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepNormal/FootstepNormal23.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepNormal/FootstepNormal24.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepNormal/FootstepNormal25.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepNormal/FootstepNormal26.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepNormal/FootstepNormal27.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepNormal/FootstepNormal28.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepNormal/FootstepNormal29.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepNormal/FootstepNormal30.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepNormal/FootstepNormal31.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepNormal/FootstepNormal32.wav"]
var footstep_sounds_concrete_slow = ["res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepWalk/FootstepWalk1.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepWalk/FootstepWalk2.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepWalk/FootstepWalk3.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepWalk/FootstepWalk4.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepWalk/FootstepWalk5.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepWalk/FootstepWalk6.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepWalk/FootstepWalk7.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepWalk/FootstepWalk8.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepWalk/FootstepWalk9.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepWalk/FootstepWalk10.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepWalk/FootstepWalk11.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepWalk/FootstepWalk12.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepWalk/FootstepWalk13.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepWalk/FootstepWalk14.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepWalk/FootstepWalk15.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepWalk/FootstepWalk16.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepWalk/FootstepWalk17.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepWalk/FootstepWalk18.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepWalk/FootstepWalk19.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepWalk/FootstepWalk20.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepWalk/FootstepWalk21.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepWalk/FootstepWalk22.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepWalk/FootstepWalk23.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepWalk/FootstepWalk24.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepWalk/FootstepWalk25.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepWalk/FootstepWalk26.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepWalk/FootstepWalk27.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepWalk/FootstepWalk28.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepWalk/FootstepWalk29.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepWalk/FootstepWalk30.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepWalk/FootstepWalk31.wav", "res://Assets/Sounds/Player/Footstep/Footstep Concrete/FootstepWalk/FootstepWalk32.wav"]
var step_sound_dict = {
	"concrete" : [footstep_sounds_concrete, footstep_sounds_concrete_slow] 
}
const SPEED = 2.5
const SPRINTSPEED = 7.0
const CROUCHSPEED = 1.5
const JUMP_VELOCITY = 2.5
const MAX_STEP_HEIGHT = 0.5
var snapped_to_stairs = false
var mouse_sens = 0.0035
@export var rot_x : float = 0
@export var rot_y : float = 0
var crouch = false
var crouchtoggle = true
var camerapos = null
var basefov = null
var zoomfov = null
@onready var checkpoint = self.global_position
var doublejump_free = true
@onready var magtext = %magtext
var default_weapon_spot : Vector3 = Vector3(0,0,0)
@export var weapon_wobble_amount : float = 0.2
@export var weapon_rotation_amount : float = 0.05
var mouse_location : Vector2
var zooming : bool = false
var health_loop_stop : bool = false
var queued = null
var call_equip_deagle = Callable(self, "equip_deagle")
var call_equip_rifle = Callable(self, "equip_rifle")
var call_equip_shotgun = Callable(self, "equip_shotgun")
var queued_help = {
	"handgun" : call_equip_deagle,
	"rifle" : call_equip_rifle,
	"shotgun" : call_equip_shotgun
}
@warning_ignore("unused_signal")
signal dead
@warning_ignore("unused_signal")
signal levelend
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	#if resetinven == true:
		#Inven.itemsheld = []
	if passive_glow == false:
		$OmniLight3D.visible = false
	settings_update()
	%Bobbloid.play("wobble")
	%Bobbloid.pause()
	$GunLayer/CamNode3D/CamSmooth/PCamera/InteractWindowDetect.area_entered.connect(_on_interact_window_detect_body_entered)
	$GunLayer/CamNode3D/CamSmooth/PCamera/InteractWindowDetect.area_exited.connect(_on_interact_window_detect_body_exited)
	self.transform.basis = Basis()
	self.rotate_object_local(Vector3(0, 1, 0), rot_x) # first rotate in Y
	%PCamera.transform.basis = Basis() # reset rotation
	%PCamera.rotate_object_local(Vector3(1, 0, 0), rot_y) # then rotate in X
	await get_tree().process_frame
	#self.transform.basis = Basis()
	#self.rotate_object_local(Vector3(0, 1, 0), rot_x) # first rotate in Y
	#%PCamera.transform.basis = Basis() # reset rotation
	#%PCamera.rotate_object_local(Vector3(1, 0, 0), rot_y) # then rotate in X
	PlayerStatus.keepplayer = self

func is_too_steep(normal : Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > self.floor_max_angle

func camera_stair_smoothing():
	if camerapos == null:
		camerapos = %CamSmooth.global_position
		
func slide_cam_back(delta):
	if camerapos == null:
		return
	%CamSmooth.global_position.y = camerapos.y
	%CamSmooth.position.y = clampf(%CamSmooth.position.y, -0.55,0.55)
	var moveamount = max(self.velocity.length() * delta, SPEED/2 * delta)
	%CamSmooth.position.y = move_toward(%CamSmooth.position.y,0.0, moveamount)
	camerapos = %CamSmooth.global_position
	if %CamSmooth.position.y == 0:
		camerapos = null

func settings_update():
	var config = ConfigFile.new()
	var conf = config.load("user://settings.cfg")
	#if conf != OK:
		#config.set_value("Control", "crouchtoggle", false)
		#config.set_value("Control", "mouse_sens", 0.0035)
		#config.set_value("Control", "fov", 90)
		#config.set_value("Sound", "vol", 100)
		#config.set_value("Sound", "sfxvol", 100)
		#config.save("user://settings.cfg")
	#crouchtoggle = config.get_value("Control","crouchtoggle")
	mouse_sens = config.get_value("Control","mouse_sens")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	basefov = config.get_value("Control","fov")
	zoomfov = basefov * 0.7
	var volpercent = config.get_value("Sound","vol")
	var gunvolpercent = config.get_value("Sound","gunvol")
	var voicevolpercent = config.get_value("Sound","voicevol")
	var worldvolpercent = config.get_value("Sound","worldvol")
	var busid = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(busid, linear_to_db(volpercent/100))
	busid = AudioServer.get_bus_index("Guns")
	AudioServer.set_bus_volume_db(busid, linear_to_db(gunvolpercent/100))
	busid = AudioServer.get_bus_index("World")
	AudioServer.set_bus_volume_db(busid, linear_to_db(worldvolpercent/100))
	busid = AudioServer.get_bus_index("Voices")
	AudioServer.set_bus_volume_db(busid, linear_to_db(voicevolpercent/100))
	%PCamera.fov = basefov
	%GunCam.fov = basefov

func _snap_up_stairs_check(delta) -> bool:
	if not is_on_floor() and not snapped_to_stairs: return false
	# Don't snap stairs if trying to jump, also no need to check for stairs ahead if not moving
	if self.velocity.y > 0 or (self.velocity * Vector3(1,0,1)).length() == 0: return false
	var expected_move_motion = self.velocity * Vector3(1,0,1) * delta
	var step_pos_with_clearance = self.global_transform.translated(expected_move_motion + Vector3(0, MAX_STEP_HEIGHT * 2, 0))
	# Run a body_test_motion slightly above the pos we expect to move to, towards the floor.
	#  We give some clearance above to ensure there's ample room for the player.
	#  If it hits a step <= MAX_STEP_HEIGHT, we can teleport the player on top of the step
	#  along with their intended motion forward.
	var down_check_result = KinematicCollision3D.new()
	if (self.test_move(step_pos_with_clearance, Vector3(0,-MAX_STEP_HEIGHT*2,0), down_check_result)
	and (down_check_result.get_collider().is_class("StaticBody3D") or down_check_result.get_collider().is_class("CSGShape3D"))):
		var step_height = ((step_pos_with_clearance.origin + down_check_result.get_travel()) - self.global_position).y
		# Note I put the step_height <= 0.01 in just because I noticed it prevented some physics glitchiness
		# 0.02 was found with trial and error. Too much and sometimes get stuck on a stair. Too little and can jitter if running into a ceiling.
		# The normal character controller (both jolt & default) seems to be able to handled steps up of 0.1 anyway
		if step_height > MAX_STEP_HEIGHT or step_height <= 0.01 or (down_check_result.get_position() - self.global_position).y > MAX_STEP_HEIGHT: return false
		%StairsForward.global_position = down_check_result.get_position() + Vector3(0,MAX_STEP_HEIGHT,0) + expected_move_motion.normalized() * 0.1
		%StairsForward.force_raycast_update()
		if %StairsForward.is_colliding() and not is_too_steep(%StairsForward.get_collision_normal()):
			camera_stair_smoothing()
			self.global_position = step_pos_with_clearance.origin + down_check_result.get_travel()
			apply_floor_snap()
			snapped_to_stairs = true
			$StairsForward.position.x = 0
			$StairsForward.position.y = -0.45
			$StairsForward.position.z = -0.79
			return true
	$StairsForward.position.x = 0
	$StairsForward.position.y = -0.45
	$StairsForward.position.z = -0.79
	return false

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
		stepqueued = true
	if cam_locked:
		if instant_cam_snap:
			%PCamera.rotation_degrees.x = cam_pan.x
			rotation_degrees.y = cam_pan.y
			%PCamera.rotation_degrees.z = cam_pan.z
		else:
			%PCamera.rotation_degrees.x = lerp(%PCamera.rotation_degrees.x, cam_pan.x, 0.1)
			rotation_degrees.y = lerp(rotation_degrees.y, cam_pan.y, 0.1)
			%PCamera.rotation_degrees.z = lerp(%PCamera.rotation_degrees.z, cam_pan.z, 0.1)
	if move_locked:
		global_position.x = lerp(global_position.x, move_spot.x, 0.1)
		global_position.y = lerp(global_position.y, move_spot.y, 0.1)
		global_position.z = lerp(global_position.z, move_spot.z, 0.1)
	#!Sprint/Dash code: only one at a time, decide what you'd prefer later
	#var sprint = Input.is_action_pressed("move_sprint")
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forw", "move_back")
	var direction = ((self.transform.basis) * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if crouch == true:
			velocity.x = direction.x * CROUCHSPEED
			velocity.z = direction.z * CROUCHSPEED
		else:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		if zooming:
			velocity.x = velocity.x / 2
			velocity.z = velocity.z / 2
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED-1.5)
		velocity.z = move_toward(velocity.z, 0, SPEED-1.5)
		footstep_val = 6
	#if Input.is_action_just_pressed("flashlight"): #Flashlight stuff
		#if smgready==true:
			#SMG.flashlight()
	#if Input.is_action_just_pressed("move_crouch"): #Crouch stuff
		#if crouch == false:
			#%PlayerAnim.play("crouch")
			#crouch = true
		#elif crouch == true and crouchtoggle == true:
			#if not %CrouchCheck.is_colliding():
				#%PlayerAnim.play("uncrouch")
				#crouch = false
			#else: trying_uncrouch = true
	#if Input.is_action_just_released("move_crouch") and crouchtoggle == false:
		#if crouch == true:
			#if not %CrouchCheck.is_colliding():
				#%PlayerAnim.play("uncrouch")
				#crouch = false
			#else:
				#trying_uncrouch = true
	if Input.is_action_just_pressed("zoom"):
		if current_weapon != null:
			if current_weapon.reloading == false:
				current_weapon.zooming = true
			else:
				current_weapon.zoom_after_reload = true
			zooming = true
	if Input.is_action_just_released("zoom"):
		if current_weapon != null:
			current_weapon.zooming = false
			current_weapon.zoom_after_reload = false
			zooming = false
	if Input.is_action_just_pressed("shoot"):
		if current_weapon != null:
			if not current_weapon.full_auto:
				current_weapon.shoot()
	if Input.is_action_pressed("shoot"):
		if current_weapon != null:
			if current_weapon.full_auto:
				current_weapon.shoot()
	if Input.is_action_just_pressed("reload"):
		if current_weapon != null:
			current_weapon.reload()
	if trying_uncrouch:
		if not %CrouchCheck.is_colliding():
			$PlayerAnim.play("uncrouch")
			trying_uncrouch = false
			crouch = false
	if Input.is_action_pressed("lean_left") and not cam_locked:
		%PCamera.rotation_degrees.z = lerp(%PCamera.rotation_degrees.z, 15.0, 0.08)
		%PCamera.position.x = lerp(%PCamera.position.x, -0.4, 0.08)
	elif Input.is_action_pressed("lean_right") and not cam_locked:
		%PCamera.rotation_degrees.z = lerp(%PCamera.rotation_degrees.z, -15.0, 0.08)
		%PCamera.position.x = lerp(%PCamera.position.x, 0.4, 0.08)
	elif rumbling == false:
		%PCamera.rotation_degrees.z = lerp(%PCamera.rotation_degrees.z, 0.0, 0.05)
		%PCamera.position.x = lerp(%PCamera.position.x, 0.0, 0.1)
	if rumbling:
		rumble()
	if is_on_floor():
		if stepqueued:
			footstep()
			stepqueued = false
		doublejump_free = true
		if velocity.x != 0 or velocity.z != 0:
			footstep_val -= 1
			if footstep_val <= 0:
				footstep()
	#weaponbobble()
	if not _snap_up_stairs_check(delta) and not move_locked:
		move_and_slide()
	slide_cam_back(delta)
	cam_tilt(input_dir.x)
	weapon_tilt(input_dir.x)
	weapon_wobble()
	weapon_sway(velocity.length())
	%GunCam.transform = %PCamera.transform
	%GunCam.transform = %GunCam.transform.rotated(Vector3(0,1,0), self.rotation.y)
	%GunCam.global_position = %PCamera.global_position

func cam_tilt(x):
	%CamSmooth.rotation.z = lerp(%CamSmooth.rotation.z, -x * weapon_rotation_amount, 0.1)

func weapon_tilt(x):
	%WeaponBobble.rotation.z = lerp(%WeaponBobble.rotation.z, -x * weapon_wobble_amount, 0.1)

func weapon_wobble():
	mouse_location = lerp(mouse_location, Vector2.ZERO, 0.1)
	%WeaponBobble.rotation.x = lerp(%WeaponBobble.rotation.x, mouse_location.y * weapon_rotation_amount, 0.1)
	%WeaponBobble.rotation.y = lerp(%WeaponBobble.rotation.y, mouse_location.x * weapon_rotation_amount, 0.1)

func weapon_sway(velo : float):
	if velo > 0:
		var bob_level : float = 0.01
		var bob_frequency : float = 0.01
		%WeaponBobble.position.y = lerp(%WeaponBobble.position.y, default_weapon_spot.y + sin(Time.get_ticks_msec() * bob_frequency) * bob_level, 0.1)
		%WeaponBobble.position.x = lerp(%WeaponBobble.position.x, default_weapon_spot.x + sin(Time.get_ticks_msec() * bob_frequency * 0.5) * bob_level, 0.1)
	else:
		%WeaponBobble.position.y = lerp(%WeaponBobble.position.y, default_weapon_spot.y, 0.1)
		%WeaponBobble.position.x = lerp(%WeaponBobble.position.y, default_weapon_spot.x, 0.1)

func rumble():
	if rumble_x_start == 0:
		rumble_x_start = %PCamera.position.x
	if rumble_y_start == 0:
		rumble_y_start = %PCamera.position.y
	if snapped(%PCamera.position.x, 0.01) == snapped(rumble_x_start + rumble_x_destination, 0.01) or rumble_x_destination == 0:
		rumble_x_destination = randf_range(-0.025, 0.025)
	if snapped(%PCamera.position.y, 0.01) == snapped(rumble_y_start + rumble_y_destination, 0.01) or rumble_y_destination == 0:
		rumble_y_destination = randf_range(-0.025, 0.025)
	%PCamera.position.x = lerp(%PCamera.position.x, rumble_x_start + rumble_x_destination, 0.2)
	%PCamera.position.y = lerp(%PCamera.position.y, rumble_y_start + rumble_y_destination, 0.2)

func footstep():
	var steps_current : Array
	var smallstep : bool = false
	if zooming != true:
		steps_current = step_sound_dict[step_sound_type][0]
	else: 
		steps_current = step_sound_dict[step_sound_type][1]
		smallstep = true
	var steps_range : int = steps_current.size() - 1 
	$Footstep.stream = load(steps_current[randi_range(0,steps_range)])
	$Footstep.play()
	if smallstep == false: footstep_val = 30
	else: footstep_val = 40

func _input(event):
	if event is InputEventMouseMotion:
		if cam_locked == false:
			var rot_z = %PCamera.rotation.z
			rot_x -= event.relative.x * mouse_sens
			self.transform.basis = Basis()
			self.rotate_object_local(Vector3(0, 1, 0), rot_x) # first rotate in Y
			if (rot_y - event.relative.y * mouse_sens) < 1.3 and (rot_y - event.relative.y * mouse_sens) > -1.3:
				rot_y -= event.relative.y * mouse_sens
			%PCamera.transform.basis = Basis() # reset rotation
			%PCamera.rotate_object_local(Vector3(1, 0, 0), rot_y) # then rotate in X
			%PCamera.rotate_object_local(Vector3(0, 0, 1), rot_z)
			mouse_location = event.relative

	if event is InputEventKey:
		if Input.is_action_just_pressed("move_jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			checkpoint = self.global_position
		if Input.is_action_just_pressed("0"):
			pass
		elif Input.is_action_just_pressed("1"):
			if current_weapon != null:
				if not current_weapon.is_in_group("handgun"): queued = "handgun"
				current_weapon.unequip()
			else:
				equip_deagle()
		elif Input.is_action_just_pressed("2"):
			if current_weapon != null:
				if not current_weapon.is_in_group("rifle"): queued = "rifle"
				current_weapon.unequip()
			else:
				equip_rifle()
		elif Input.is_action_just_pressed("3"):
			if current_weapon != null:
				if not current_weapon.is_in_group("shotgun"): queued = "shotgun"
				current_weapon.unequip()
			else:
				equip_shotgun()
		elif Input.is_action_just_pressed("4"):
			pass
		#Remove 5 to F9 for general release, these are cheats/debug tools.
		elif Input.is_action_just_pressed("5"):
			PlayerStatus.level_change("res://Scenes/Levels/rust_floor.tscn")
		elif Input.is_action_just_pressed("6"):
			pass
		elif Input.is_action_just_pressed("7"):
			pass
		elif Input.is_action_just_pressed("8"):
			rumbling = true
		elif Input.is_action_just_pressed("9"):
			print(get_tree().root.get_children()[-1].get_children())
		#elif Input.is_action_just_pressed("f5"):
			#pass
		#elif Input.is_action_just_pressed("f9"):
			#pass
		if Input.is_action_just_pressed("interact"):
			if %Interact.is_colliding(): 
				var body = (%Interact.get_collider()).get_parent()
				if body.has_method("interact"):
					body.interact()
				elif body.has_method("interact_with_player"):
					body.interact_with_player(self)

#func save():
	#var save_dictionary = {
		#"filename" : get_scene_file_path(),
		#"parent" : "level",
		#"pos_x" : position.x, # Vector2 is not supported by JSON
		#"pos_y" : position.y,
		#"pos_z" : position.z,
		#"rot_x" : rot_x,
		#"rot_y" : rot_y,
		#"process_mode" : process_mode
	#}
	#return save_dictionary

func look_to_dir(dir : Vector3):
	cam_locked = true
	cam_pan = dir

func move_to_pos(pos : Vector3):
	move_locked = true
	move_spot = pos
	

func game_over():
	emit_signal("dead")

func weaponbobble():
	if velocity.x != 0 or velocity.z != 0:
		%Bobbloid.play()
	else:
		%Bobbloid.pause()

func make_guns_visible(make_visible : bool = true):
	if make_visible:
		%WeaponBobble.visible = true
	else:
		%WeaponBobble.visible = false

func take_damage(x):
	#255 - (2.55 * PlayerStatus.player_health)
	PlayerStatus.player_health -= x
	if PlayerStatus.player_health > 0:
		%Health.modulate = Color(1, 1, 1, 1.0 - (float(PlayerStatus.player_health) / 100))
		$HealthRegen.start()
		if PlayerStatus.player_health <= 40:
			%HealthAnims.play("HP bar shake")
	if PlayerStatus.player_health <= 0:
		PlayerStatus.player_health = 0
		#%heltext.text = "%s" % str(PlayerStatus.healthcurrent)
		game_over()

func hud_pixelate(on : bool = false):
	if on == true:
		$"CamNode3D/CanvasLayer/Pixelate Hud".visible = true
	else:
		$"CamNode3D/CanvasLayer/Pixelate Hud".visible = false

func pixelate_off():
	%Pixelate.visible = false

func show_hud(on : bool = false):
	var hud_elements = [$CamNode3D/CanvasLayer/Health, $"%PopUpText"]
	if on == true:
		for i in hud_elements:
			i.visible = true
	else:
		for i in hud_elements:
			i.visible = false

func show_interact_prompt(on : bool = false):
	if on == false:
		%InteractPrompt.visible = false
	else:
		%InteractPrompt.visible = true

func travel_with_fade(level, coord):
	stored_level = level
	stored_coord = coord
	$HudAnim.play("FadeToBlack")

func heal():
	if not (PlayerStatus.player_health + 1) > PlayerStatus.MAX_HEALTH and $HealthRegen.time_left == 0:
		PlayerStatus.player_health += 1
		await get_tree().create_timer(0.05).timeout
		heal()
	else:
		PlayerStatus.player_health = 100
	%Health.modulate = Color(1, 1, 1, 1.0 - (float(PlayerStatus.player_health) / 100))
	if PlayerStatus.player_health > 40:
		health_loop_stop = true


func endlevel():
	%LevelEnd.visible = true
	%PlayerAnim.play("FadeToBlack")

func _on_player_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "FadeToBlack":
		emit_signal("levelend")

func pixelatetoggle():
	if %Pixelate.visible == true:
		%Pixelate.visible = false
	elif %Pixelate.visible == false:
		%Pixelate.visible = true

func glowtoggle(x):
	if x == null:
		if $OmniLight3D.visible == true:
			$OmniLight3D.visible = false
		elif $OmniLight3D.visible == false:
			$OmniLight3D.visible = true
	elif x == true:
		$OmniLight3D.visible = true
	elif x == false:
		$OmniLight3D.visible = false
		
func equip_queued():
	queued_help[queued].call()
	queued = null

func equip_deagle():
	var deagle = deagle_load.instantiate()
	%WeaponBobble.add_child(deagle)
	deagle.unequiped.connect(_on_unequipped)
	deagle.just_shot.connect(_gun_shot)
	deagle.reload_ended.connect(_gun_reload)
	deagle.ready_to_fire.connect(_gun_readied)
	current_weapon = deagle

func equip_rifle():
	var rifle = rifle_load.instantiate()
	%WeaponBobble.add_child(rifle)
	rifle.unequiped.connect(_on_unequipped)
	rifle.just_shot.connect(_gun_shot)
	rifle.reload_ended.connect(_gun_reload)
	rifle.ready_to_fire.connect(_gun_readied)
	current_weapon = rifle

func equip_shotgun():
	var shotgun = shotgun_load.instantiate()
	%WeaponBobble.add_child(shotgun)
	shotgun.unequiped.connect(_on_unequipped)
	shotgun.just_shot.connect(_gun_shot)
	shotgun.reload_ended.connect(_gun_reload)
	shotgun.ready_to_fire.connect(_gun_readied)
	current_weapon = shotgun

func handgun_ammo_count_update():
	#$GunLayer/CamNode3D/CanvasLayer/ScrollContainer.visible = true
	var reset_hud = %BulletCounter.get_children()
	for i in reset_hud: i.queue_free()
	for i in range(PlayerStatus.bullets_in_deagle):
		var new_label = Label.new()
		new_label.label_settings = load("res://Resources/ammo_count_label.tres")
		new_label.text = ".357 Hollow Point Round"
		new_label.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		new_label.PRESET_CENTER_RIGHT
		%BulletCounter.add_child(new_label)

func rifle_ammo_count_update():
	#$GunLayer/CamNode3D/CanvasLayer/ScrollContainer.visible = true
	var reset_hud = %BulletCounter.get_children()
	for i in reset_hud: i.queue_free()
	for i in range(PlayerStatus.bullets_in_rifle):
		var new_label = Label.new()
		new_label.label_settings = load("res://Resources/ammo_count_label.tres")
		new_label.text = "5.45x45 Hollow Point Round"
		new_label.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		new_label.PRESET_CENTER_RIGHT
		%BulletCounter.add_child(new_label)

func shotgun_ammo_count_update():
	#$GunLayer/CamNode3D/CanvasLayer/ScrollContainer.visible = true
	var reset_hud = %BulletCounter.get_children()
	for i in reset_hud: i.queue_free()
	for i in range(PlayerStatus.bullets_in_shotgun):
		var new_label = Label.new()
		new_label.label_settings = load("res://Resources/ammo_count_label.tres")
		new_label.text = "12G Buckshot round"
		new_label.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		new_label.PRESET_CENTER_RIGHT
		%BulletCounter.add_child(new_label)

func check_warp():
	if PlayerStatus.warp_to != null:
		self.global_position = PlayerStatus.warp_to
		PlayerStatus.warp_to = null

func _on_hud_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "FadeToBlack":
		PlayerStatus.level_change(stored_level, stored_coord)
		get_parent().queue_free()

func _on_pop_up_timer_timeout() -> void:
	if $HudAnim.is_playing() == false:
		$HudAnim.play("TextFadeAway")

func _on_interact_window_detect_body_entered(body: Node3D) -> void:
	body = body.get_parent()
	if body.has_method("interact") and body.is_in_group("interactable") and not body.is_in_group("interact_hidden") or body.has_method("interact_with_player") and body.is_in_group("interactable") and not body.is_in_group("interact_hidden") or body.is_in_group("door") and not body.is_in_group("interact_hidden"):
		if body.is_in_group("door"): 
			for i in 2: body = body.get_parent()
			if body.is_in_group("interact_hidden"): return
		%InteractPrompt.visible = true
		if "interact_text" in body:
			var new_text = body.interact_text
			$GunLayer/CamNode3D/CanvasLayer/InteractPrompt/InteractText.text = new_text
		else:
			var button = str(InputMap.action_get_events("interact")[0].as_text()).split(" ")[0]
			$GunLayer/CamNode3D/CanvasLayer/InteractPrompt/InteractText.text = "%s: Interact" %[str(button)]


func _on_interact_window_detect_body_exited(body: Node3D) -> void:
	body = body.get_parent()
	if body.has_method("interact") or body.has_method("interact_with_player") or body.is_in_group("door"):
		%InteractPrompt.visible = false


func _on_footstep_finished() -> void:
	pass
	#$Footstep.volume_db = 0

func _on_unequipped():
	$GunLayer/CamNode3D/CanvasLayer/ScrollContainer.visible = false
	if queued != null:
		equip_queued()

func _gun_shot():
	%BulletCounter.get_children()[-1].queue_free()

func _gun_reload():
	if current_weapon.name == "PlayerDeagle" : handgun_ammo_count_update()
	elif current_weapon.name == "PlayerRifle" : rifle_ammo_count_update()
	elif current_weapon.name == "PlayerShotgun" : shotgun_ammo_count_update()

func _gun_readied():
	if current_weapon.name == "PlayerDeagle" : handgun_ammo_count_update()
	elif current_weapon.name == "PlayerRifle" : rifle_ammo_count_update()
	elif current_weapon.name == "PlayerShotgun" : shotgun_ammo_count_update()

func _on_quit_pressed() -> void:
	get_tree().paused = false
	if PlayerStatus.keepplayer != null:
		PlayerStatus.keepplayer.queue_free()
	#get_tree().change_scene_to_packed(load("res://Scenes/Menus/title.tscn"))


func _on_health_regen_timeout() -> void:
	heal()


func _on_health_anims_animation_finished(anim_name: StringName) -> void:
	if anim_name == "HP bar shake":
		if health_loop_stop == true:
			%HealthAnims.play("RESET")
			health_loop_stop = false
		else:
			%HealthAnims.play("HP bar shake")
