extends CharacterBody3D
@export var resetinven : bool
@export var passive_glow : bool
@onready var maingame = self.get_parent_node_3d()
@export var current_weapon : Node3D
var trying_uncrouch : bool = false
var stored_level
var stored_coord
var deagle_load = preload("res://Scenes/Guns/player_deagle.tscn")
var stepqueued : bool = false
var footstep_val : float = 30
var footstep_sounds_metal = ["res://Assets/Sounds/FootstepMetal1.wav","res://Assets/Sounds/FootstepMetal2.wav","res://Assets/Sounds/FootstepMetal3.wav","res://Assets/Sounds/FootstepMetal4.wav"]
const SPEED = 2.5
const SPRINTSPEED = 7.0
const CROUCHSPEED = 1.5
const JUMP_VELOCITY = 2.5
const MAX_STEP_HEIGHT = 0.5
var snapped_to_stairs = false
var mouse_sens = 0.0035
var rot_x = 0
var rot_y = 0
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
	var config = ConfigFile.new()
	var conf = config.load("user://settings.cfg")
	if conf != OK:
		config.set_value("Control", "crouchtoggle", false)
		config.set_value("Control", "mouse_sens", 0.0035)
		config.set_value("Control", "fov", 90)
		config.set_value("Sound", "vol", 100)
		config.set_value("Sound", "sfxvol", 100)
		config.save("user://settings.cfg")
	crouchtoggle = config.get_value("Control","crouchtoggle")
	mouse_sens = config.get_value("Control","mouse_sens")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	basefov = config.get_value("Control","fov")
	zoomfov = basefov * 0.7
	var volpercent = config.get_value("Sound","vol")
	var sfxvolpercent = config.get_value("Sound","sfxvol")
	var busid = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(busid,linear_to_db(volpercent/100))
	%PCamera.fov = basefov
	%GunCam.fov = basefov
	%Bobbloid.play("wobble")
	%Bobbloid.pause()
	$GunLayer/CamNode3D/CamSmooth/PCamera/InteractWindowDetect.area_entered.connect(_on_interact_window_detect_body_entered)
	$GunLayer/CamNode3D/CamSmooth/PCamera/InteractWindowDetect.area_exited.connect(_on_interact_window_detect_body_exited)
	await get_tree().process_frame
	self.transform.basis = Basis()
	self.rotate_object_local(Vector3(0, 1, 0), rot_x) # first rotate in Y
	%PCamera.transform.basis = Basis() # reset rotation
	%PCamera.rotate_object_local(Vector3(1, 0, 0), rot_y) # then rotate in X
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
	if Input.is_action_just_pressed("move_crouch"): #Crouch stuff
		if crouch == false:
			%PlayerAnim.play("crouch")
			crouch = true
		elif crouch == true and crouchtoggle == true:
			if not %CrouchCheck.is_colliding():
				%PlayerAnim.play("uncrouch")
				crouch = false
			else: trying_uncrouch = true
	if Input.is_action_just_released("move_crouch") and crouchtoggle == false:
		if crouch == true:
			if not %CrouchCheck.is_colliding():
				%PlayerAnim.play("uncrouch")
				crouch = false
			else:
				trying_uncrouch = true
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
			current_weapon.shoot()
	if Input.is_action_just_pressed("reload"):
		if current_weapon != null:
			current_weapon.reload()
	if trying_uncrouch:
		if not %CrouchCheck.is_colliding():
			$PlayerAnim.play("uncrouch")
			trying_uncrouch = false
			crouch = false
	if Input.is_action_pressed("lean_left"):
		%PCamera.rotation_degrees.z = lerp(%PCamera.rotation_degrees.z, 15.0, 0.08)
		%PCamera.position.x = lerp(%PCamera.position.x, -0.4, 0.08)
	elif Input.is_action_pressed("lean_right"):
		%PCamera.rotation_degrees.z = lerp(%PCamera.rotation_degrees.z, -15.0, 0.08)
		%PCamera.position.x = lerp(%PCamera.position.x, 0.4, 0.08)
	else:
		%PCamera.rotation_degrees.z = lerp(%PCamera.rotation_degrees.z, 0.0, 0.05)
		%PCamera.position.x = lerp(%PCamera.position.x, 0.0, 0.1)
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
	if not _snap_up_stairs_check(delta):
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

func footstep():
	$Footstep.stream = load(footstep_sounds_metal[randi_range(0,3)])
	$Footstep.play()
	footstep_val = 30

func _input(event):
	if event is InputEventMouseMotion:
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
				queued = "handgun"
				current_weapon.unequip()
			else:
				equip_deagle()
		elif Input.is_action_just_pressed("2"):
			pass
		elif Input.is_action_just_pressed("3"):
			pass
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
			take_damage(10)
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
	pass

func equip_deagle():
	var deagle = deagle_load.instantiate()
	%WeaponBobble.add_child(deagle)
	deagle.unequiped.connect(_on_unequipped)
	current_weapon = deagle

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
	if body.has_method("interact") and not body.is_in_group("interact_hidden") or body.has_method("interact_with_player") and not body.is_in_group("interact_hidden") or body.is_in_group("door") and not body.is_in_group("interact_hidden"):
		if body.is_in_group("door"): 
			for i in 2: body = body.get_parent()
			if body.is_in_group("interact_hidden"): return
		%InteractPrompt.visible = true
		if "interact_text" in body:
			var new_text = body.interact_text
			$CamNode3D/CanvasLayer/InteractPrompt/InteractText.text = new_text
		else:
			var button = str(InputMap.action_get_events("interact")[0].as_text()).split(" ")[0]
			$CamNode3D/CanvasLayer/InteractPrompt/InteractText.text = "%s: Interact" %[str(button)]


func _on_interact_window_detect_body_exited(body: Node3D) -> void:
	body = body.get_parent()
	if body.has_method("interact") or body.has_method("interact_with_player") or body.is_in_group("door"):
		%InteractPrompt.visible = false


func _on_footstep_finished() -> void:
	$Footstep.volume_db = 0

func _on_unequipped():
	if queued != null:
		equip_queued()

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
