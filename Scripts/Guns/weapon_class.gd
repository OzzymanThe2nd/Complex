extends Node3D
class_name weapon
var player : Node3D
var default_cast_rot : Vector3 
var y_spread : float = 0.0
var x_spread :float = 0.0
@onready var muzzle_flash = preload("res://Scenes/Guns/muzzle_flash.tscn")
@onready var bullet_hole = preload("res://Scenes/Guns/bullet_hole.tscn")
@export var heavy : bool = false
@export var casing = "res://Scenes/Guns/casing.tscn"
@export var shootable : bool = false
@export var kickback_level : float = 0.1
@export var max_mag : int = 8
@export var damage : float = 1
@export var heat_generated : float = 5.1
@export var zoom_position : Vector3 = Vector3(-0.258, 0.095, 0.0)
@export var zoom_in_speed : float = 0.035
@export var zoom_in_z_speed : float = 0.025
@export var full_auto : bool = false
@export var left_recoil_minimum : float = 0.085
@export var left_recoil_maximum : float = 0.105
@export var right_recoil_minimum : float = -0.105
@export var right_recoil_maximum : float = -0.085
@export var y_spread_minimum : float = -0.5
@export var y_spread_maximum : float = 0.5
@export var shotsounds = ["res://Assets/Sounds/Weapons/Heavy Pistol/Shooting/HeavyPistolShot1.wav","res://Assets/Sounds/Weapons/Heavy Pistol/Shooting/HeavyPistolShot2.wav","res://Assets/Sounds/Weapons/Heavy Pistol/Shooting/HeavyPistolShot3.wav","res://Assets/Sounds/Weapons/Heavy Pistol/Shooting/HeavyPistolShot4.wav"]
@export var trail = "res://Scenes/Guns/projectile_trail.tscn"
var active_shotsounds = []
var spot_of_last_shot : Vector3
var default_arm_pos : Vector3
var shoot_direction = null
var zooming : bool = false
var zoom_after_reload : bool = false
var reloading : bool = false
var heat : float = 0.0
var jammed : bool = false
var current_bullets = 0
var shotgun_casts = []
signal unequiped
signal just_shot
signal reload_ended
signal ready_to_fire
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	casing = load(casing)
	trail = load(trail)
	player = PlayerStatus.keepplayer
	default_cast_rot = rotation
	y_spread = rotation.y
	x_spread = rotation.z
	default_arm_pos = $Player_Arms.rotation
	set_current_bullets()
	check_jam_state()
	set_connections()
	if jammed == true:
		$AnimationPlayer.play("equip_jam")
	elif current_bullets > 0 and jammed == false:
		$AnimationPlayer.play("equip")
	elif jammed == false:
		$AnimationPlayer.play("equip_empty")
	if is_in_group("shotgun"):
		for i in 25:
			var new_shot = load("res://Scenes/Guns/shotgun_cast.tscn").instantiate()
			add_child(new_shot)
			new_shot.global_position = %ShootCast.global_position
			new_shot.global_rotation = %ShootCast.global_rotation
			new_shot.rotation_degrees.x = 0
			shotgun_casts.append(new_shot)
	await get_tree().process_frame
	visible = true

func set_connections():
	pass

func set_current_bullets():
	pass

func check_jam_state():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not zooming:
		rotation.y = lerp(rotation.y, y_spread, 0.035)
		rotation.z = lerp(rotation.z, x_spread, 0.035)
	if $ShotRecovery.time_left != 0:
		position.z = lerp(position.z, spot_of_last_shot.z + kickback_level, 0.1)
		position.y = lerp(position.y, spot_of_last_shot.y + kickback_level / 2, 0.1)
		$Player_Arms.rotation.x = lerp($Player_Arms.rotation.x, clamp($Player_Arms.rotation.x + 0.1, 0.0, 0.8), 0.125)
	else:
		if zooming:
			position.z = lerp(position.z, zoom_position.z, zoom_in_z_speed)
			if heavy:
				position.x = lerp(position.x, zoom_position.x + (x_spread), zoom_in_speed)
				position.y = lerp(position.y, zoom_position.y + (y_spread), zoom_in_speed)
			else:
				position.x = lerp(position.x, zoom_position.x, zoom_in_speed)
				position.y = lerp(position.y, zoom_position.y, zoom_in_speed)
			$Player_Arms.rotation.x = lerp($Player_Arms.rotation.x, default_arm_pos.x, 0.01)
		else:
			position.x = lerp(position.x, 0.0, 0.1)
			position.z = lerp(position.z, 0.0, 0.1)
			position.y = lerp(position.y, 0.0, 0.1)
	if position.z < 0.0001:
		$Player_Arms.rotation.x = lerp($Player_Arms.rotation.x, default_arm_pos.x, 0.05)
		shoot_direction = null
	if active_shotsounds.size() > 1:
		for i in active_shotsounds.size() - 1:
			active_shotsounds[i].volume_db -= 0.2
	#%ShootCast.global_position = %FlashSpawner.global_position

func heat_cool():
	heat -= 0.1
	if heat < 0.0: heat = 0.0
	if heat != 0.0:
		await get_tree().create_timer(0.05).timeout
		heat_cool()

func trail_spawn():
	var new_trail = trail.instantiate()
	%FlashSpawner.add_child(new_trail)
	new_trail.global_position = %FlashSpawner.global_position
	new_trail.look_at(%TrailGuide.global_position)

func shotgun_trail_spawn(shotcast):
	var marker = shotcast.get_node("Marker3D")
	var new_trail = trail.instantiate()
	%FlashSpawner.add_child(new_trail)
	new_trail.global_position = %FlashSpawner.global_position
	new_trail.look_at(marker.global_position)

func shoot():
	if current_bullets > 0:
		if shootable and not jammed:
			current_bullets -= 1
			just_shot.emit()
			shootable = false
			if shoot_direction == null:
				if randi_range(0,1) == 0: shoot_direction = "left"
				else: shoot_direction = "right"
			elif shoot_direction == "left": y_spread += rotation.y + randf_range(left_recoil_minimum, left_recoil_maximum)
			elif shoot_direction == "right": y_spread += rotation.y + randf_range(right_recoil_minimum, right_recoil_maximum)
			x_spread += rotation.z + randf_range(0.2, 0.3)
			y_spread = clamp(y_spread, y_spread_minimum, y_spread_maximum)
			x_spread = clamp(x_spread, -0.5, 0.5)
			var flash = muzzle_flash.instantiate()
			%FlashSpawner.add_child(flash)
			flash.follow_point = %FlashSpawner
			flash.position = %FlashSpawner.position
			heat += heat_generated
			heat_cool()
			print(heat)
			if $AnimationPlayer.current_animation == "shoot": $AnimationPlayer.stop()
			if current_bullets > 0:
				if randi_range(0, 100) < heat:
					jammed = true
					$AnimationPlayer.play("shoot_jam")
				else:
					$AnimationPlayer.play("shoot")
			else:
				$AnimationPlayer.play("shoot_final_round")
			spot_of_last_shot = position
			if not is_in_group("shotgun"):
				var target = %ShootCast.get_collider()
				if target:
					handle_impact(target, %ShootCast)
				trail_spawn()
			elif is_in_group("shotgun"):
				for new_shot in shotgun_casts:
					new_shot.rotation_degrees.y = randf_range(175.0, 185.0)
					new_shot.rotation_degrees.x = randf_range(-25.0, 25.0)
					var target = new_shot.get_collider()
					if target:
						handle_impact(target, new_shot)
					shotgun_trail_spawn(new_shot)
			var gunshot = AudioStreamPlayer.new()
			gunshot.set_bus("Guns")
			gunshot.stream = load(shotsounds[randi_range(0,(shotsounds.size() - 1))])
			PlayerStatus.loaded_level.add_child(gunshot)
			gunshot.finished.connect(_shotsound_finished.bind(gunshot))
			active_shotsounds.append(gunshot)
			gunshot.play()
			if not jammed and not get_groups().has("shotgun"):
				spawn_casing(true)
			if get_groups().has("shotgun"):
				PlayerStatus.shotgun_stunned = true
				$StunRecovery.start()
			elif get_groups().has("rifle"):
				PlayerStatus.rifle_recoil_level += 1
				$RecoilRecovery.start()
			elif get_groups().has("handgun"):
				PlayerStatus.pistol_recoil_level += 1
				$RecoilRecovery.start()
			$ShotRecovery.start()
			$ShotCooldown.start()
		else: #What to do if no ammo
			pass

func handle_impact(target, raycast):
	if target.get_collision_layer() == 1:
		await get_tree().process_frame
		var decal = bullet_hole.instantiate()
		var hit_pos = raycast.get_collision_point()
		decal.hit_pos = hit_pos
		decal.global_position = hit_pos
		decal.normal = Vector3(raycast.get_collision_normal())
		PlayerStatus.loaded_level.add_child(decal)
	elif target.get_collision_layer() == 2:
		if target.is_in_group("hobo_bone"):
			for i in range(4): target = target.get_parent()
			target.take_damage(damage)
		elif target.is_in_group("hobo_head"):
			for i in range(4): target = target.get_parent()
			target.take_damage(damage * 2.1)
		pass #Lower enemy health, blood splatter decal

func unequip():
	if $AnimationPlayer.is_playing() == false:
		shootable = false
		if current_bullets > 0:
			$AnimationPlayer.play("unequip")
		else:
			$AnimationPlayer.play("unequip_empty")

func spawn_casing(energy : bool = false):
	var spawned_casing = casing.instantiate()
	spawned_casing.gun_node = self
	if energy == false:
		spawned_casing.energy = false
	spawned_casing.global_position = %CasingSpawner.global_position
	spawned_casing.rotation = PlayerStatus.keepplayer.rotation
	%CasingSpawner.add_child(spawned_casing)

func reload():
	reloading = true
	if jammed and $ShotCooldown.time_left == 0:
		$AnimationPlayer.play("clear_jam")
	elif $ShotCooldown.time_left == 0 and current_bullets != max_mag:
		if zooming:
			zooming = false
			zoom_after_reload = true
		shootable = false
		if current_bullets > 0:
			$AnimationPlayer.play("reload")
		else:
			$AnimationPlayer.play("reload_empty")


func _on_shot_cooldown_timeout() -> void:
	y_spread = default_cast_rot.y
	x_spread = default_cast_rot.x


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "shoot" or anim_name == "shoot_final_round" or "shoot_jam":
		shootable = true
	if anim_name == "reload" or anim_name == "reload_empty":
		current_bullets = max_mag
		shootable = true
		reloading = false
		if zoom_after_reload:
			zooming = true
			zoom_after_reload = false
		reload_ended.emit()
	if anim_name == "equip" or anim_name == "equip_empty":
		shootable = true
		ready_to_fire.emit()
	if anim_name == "unequip" or anim_name == "unequip_empty":
		unequiped.emit()
		queue_free()
	if anim_name == "clear_jam":
		jammed = false
		reloading = false


func _on_shot_recovery_timeout() -> void:
	pass # Replace with function body.

func _shotsound_finished(shotsound):
	shotsound.queue_free()
	await get_tree().process_frame
	for i in active_shotsounds:
		if not is_instance_valid(i):
			active_shotsounds.erase(i)
			await get_tree().process_frame
