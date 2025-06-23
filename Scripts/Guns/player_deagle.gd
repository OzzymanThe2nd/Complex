extends Node3D
var player : Node3D
var default_cast_rot : Vector3 
var y_spread : float = 0.0
var x_spread :float = 0.0
@onready var muzzle_flash = preload("res://Scenes/Guns/muzzle_flash.tscn")
@onready var bullet_hole = preload("res://Scenes/Guns/bullet_hole.tscn")
@export var shootable : bool = false
@export var kickback_level : float = 0.1
@export var max_mag : int = 8
var spot_of_last_shot : Vector3
var default_arm_pos : Vector3
var shoot_direction = null
var zooming : bool = false
var zoom_after_reload : bool = false
var reloading : bool = false
signal unequiped
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = PlayerStatus.keepplayer
	default_cast_rot = rotation
	y_spread = rotation.y
	x_spread = rotation.z
	default_arm_pos = $Player_Arms.rotation
	if PlayerStatus.bullets_in_deagle > 0:
		$AnimationPlayer.play("equip")
	else:
		$AnimationPlayer.play("equip_empty")

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
			position.z = lerp(position.z, 0.0, 0.025)
			position.x = lerp(position.x, -0.258, 0.035)
			position.y = lerp(position.y, 0.095, 0.035)
			$Player_Arms.rotation.x = lerp($Player_Arms.rotation.x, default_arm_pos.x, 0.01)
		else:
			position.x = lerp(position.x, 0.0, 0.1)
			position.z = lerp(position.z, 0.0, 0.1)
			position.y = lerp(position.y, 0.0, 0.1)
	if position.z < 0.0001:
		$Player_Arms.rotation.x = lerp($Player_Arms.rotation.x, default_arm_pos.x, 0.05)
		shoot_direction = null
	#%ShootCast.global_position = %FlashSpawner.global_position

func shoot():
	if PlayerStatus.bullets_in_deagle > 0:
		if shootable:
			PlayerStatus.bullets_in_deagle -= 1
			shootable = false
			if shoot_direction == null:
				if randi_range(0,1) == 0: shoot_direction = "left"
				else: shoot_direction = "right"
			elif shoot_direction == "left": y_spread += rotation.y + randf_range(0.105, 0.085)
			elif shoot_direction == "right": y_spread += rotation.y + randf_range(-0.105, -0.085)
			x_spread += rotation.z + randf_range(0.2, 0.3)
			y_spread = clamp(y_spread, -0.5, 0.5)
			x_spread = clamp(x_spread, -0.5, 0.5)
			var flash = muzzle_flash.instantiate()
			%FlashSpawner.add_child(flash)
			flash.follow_point = %FlashSpawner
			flash.position = %FlashSpawner.position
			if $AnimationPlayer.current_animation == "shoot": $AnimationPlayer.stop()
			if PlayerStatus.bullets_in_deagle > 1:
				$AnimationPlayer.play("shoot")
			else:
				$AnimationPlayer.play("shoot_final_round")
			spot_of_last_shot = position
			var target = %ShootCast.get_collider()
			if target:
				if target.get_collision_layer() == 1:
					var decal = bullet_hole.instantiate()
					var hit_pos = %ShootCast.get_collision_point()
					decal.hit_pos = hit_pos
					decal.global_position = hit_pos
					decal.normal = Vector3(%ShootCast.get_collision_normal())
					PlayerStatus.loaded_level.add_child(decal)
				elif target.get_collision_layer() == 2:
					pass #Lower enemy health, blood splatter decal
			$ShotRecovery.start()
			$ShotCooldown.start()
		else: #What to do if no ammo
			pass

func unequip():
	if $AnimationPlayer.is_playing() == false:
		shootable = false
		if PlayerStatus.bullets_in_deagle > 0:
			$AnimationPlayer.play("unequip")
		else:
			$AnimationPlayer.play("unequip_empty")

func reload():
	reloading = true
	if $ShotCooldown.time_left == 0 and PlayerStatus.bullets_in_deagle != max_mag:
		if zooming:
			zooming = false
			zoom_after_reload = true
		shootable = false
		if PlayerStatus.bullets_in_deagle > 0:
			$AnimationPlayer.play("reload")
		else:
			$AnimationPlayer.play("reload_empty")


func _on_shot_cooldown_timeout() -> void:
	y_spread = default_cast_rot.y
	x_spread = default_cast_rot.x


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "shoot" or anim_name == "shoot_final_round":
		shootable = true
	if anim_name == "reload" or anim_name == "reload_empty":
		PlayerStatus.bullets_in_deagle = max_mag
		shootable = true
		reloading = false
		if zoom_after_reload:
			zooming = true
			zoom_after_reload = false
	if anim_name == "equip" or anim_name == "equip_empty":
		shootable = true
	if anim_name == "unequip" or anim_name == "unequip_empty":
		unequiped.emit()
		queue_free()


func _on_shot_recovery_timeout() -> void:
	pass # Replace with function body.
