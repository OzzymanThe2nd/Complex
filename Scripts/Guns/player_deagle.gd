extends Node3D
var player : Node3D
var default_cast_rot : Vector3 
var y_spread : float = 0.0
var x_spread :float = 0.0
@onready var muzzle_flash = preload("res://Scenes/Guns/muzzle_flash.tscn")
@onready var bullet_hole = preload("res://Scenes/Guns/bullet_hole.tscn")
@export var shootable : bool = true
@export var kickback_level : float = 0.1
var spot_of_last_shot : Vector3
var default_arm_pos : Vector3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = PlayerStatus.keepplayer
	default_cast_rot = rotation
	y_spread = rotation.y
	x_spread = rotation.z
	default_arm_pos = $Player_Arms.rotation

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation.y = lerp(rotation.y, y_spread, 0.035)
	rotation.z = lerp(rotation.z, x_spread, 0.035)
	if $ShotRecovery.time_left != 0:
		position.z = lerp(position.z, spot_of_last_shot.z + kickback_level, 0.1)
		position.y = lerp(position.y, spot_of_last_shot.y + kickback_level / 2, 0.1)
		$Player_Arms.rotation.x = lerp($Player_Arms.rotation.x, clamp($Player_Arms.rotation.x + 0.1, 0.0, 0.8), 0.1)
	else:
		position.z = lerp(position.z, 0.0, 0.1)
		position.y = lerp(position.y, 0.0, 0.1)
	if position.z < 0.0001:
		$Player_Arms.rotation.x = lerp($Player_Arms.rotation.x, default_arm_pos.x, 0.05)
	#%ShootCast.global_position = %FlashSpawner.global_position

func shoot():
	if shootable:
		shootable = false
		y_spread += rotation.y + randf_range(-0.015, -0.025)
		x_spread += rotation.z + randf_range(0.2, 0.3)
		y_spread = clamp(y_spread, -0.5, 0.3)
		x_spread = clamp(x_spread, -0.5, 0.5)
		var flash = muzzle_flash.instantiate()
		%FlashSpawner.add_child(flash)
		flash.follow_point = %FlashSpawner
		flash.position = %FlashSpawner.position
		if $AnimationPlayer.current_animation == "shoot": $AnimationPlayer.stop()
		$AnimationPlayer.play("shoot")
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


func _on_shot_cooldown_timeout() -> void:
	y_spread = default_cast_rot.y
	x_spread = default_cast_rot.x


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "shoot":
		shootable = true


func _on_shot_recovery_timeout() -> void:
	pass # Replace with function body.
