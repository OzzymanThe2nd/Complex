extends enemy_base
var shot_burst_remaining : int = 0
@export var shot_burst_range : Array = [2, 4]
# Called when the node enters the scene tree for the first time.

func _on_timer_timeout() -> void:
	if agro and not dead and $BurstCooldown.time_left == 0:
		if mag_current == 0:
			reload()
		elif not busy:
			if shot_burst_remaining == 0:
				shot_burst_remaining = randi_range(shot_burst_range[0], shot_burst_range[1])
			if $DetectPlayer.overlaps_body(player):
				shoot()
				shot_burst_remaining -= 1
				if shot_burst_remaining == 0:
					$BurstCooldown.start()
					var reload_threshold : float = float(mag_current) / float(MAG_MAX)
					if randf_range(0, 1) > reload_threshold:
						reload()

func set_connections():
	#$DespawnTimer.timeout.connect(_on_despawn_timer_timeout)
	#$DetectPlayer.body_entered.connect(_on_detect_player_body_entered)
	$AnimationPlayer.animation_finished.connect(_on_animation_player_animation_finished)

func death():
	dead = true
	for i in $hobogameready/Skeleton3D/PhysicalBoneSimulator3D.get_children():
		i.set_collision_layer_value(2, false)
	ragdoll()

func swap_to_damaged_mesh():
	$hobogameready/Skeleton3D/Hobomesh.material_override = load("res://Resources/hobo_blooded.tres")

func ragdoll():
	var velocity_dir = global_basis * Vector3.MODEL_FRONT
	$AnimationPlayer.active = false
	$hobogameready/Skeleton3D/PhysicalBoneSimulator3D.physical_bones_start_simulation()
	$"hobogameready/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone Chest".linear_velocity = (velocity_dir) * 3
	$"hobogameready/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone Spine".linear_velocity = (velocity_dir) * 2
	$"hobogameready/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone Hip".linear_velocity = (velocity_dir) * 2
	$"hobogameready/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone Neck".linear_velocity = (velocity_dir) * 4
	$RagdollTimer.start()

func _on_ragdolltimer_timeout() -> void:
	$"hobogameready/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone Chest".linear_velocity = Vector3(0,0,0)
	$"hobogameready/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone Spine".linear_velocity = Vector3(0,0,0)
	$"hobogameready/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone Hip".linear_velocity = Vector3(0,0,0)
	$"hobogameready/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone Neck".linear_velocity = Vector3(0,0,0)
	$"hobogameready/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone Neck".angular_velocity.x = 0
	$DespawnTimer.start()
