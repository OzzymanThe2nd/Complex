extends enemy_base

# Called when the node enters the scene tree for the first time.

func set_connections():
	#$DespawnTimer.timeout.connect(_on_despawn_timer_timeout)
	#$DetectPlayer.body_entered.connect(_on_detect_player_body_entered)
	pass

func _on_timer_timeout() -> void:
	if agro and not dead:
		shoot()

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
