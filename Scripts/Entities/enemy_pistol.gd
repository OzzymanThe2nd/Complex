extends enemy_base

# Called when the node enters the scene tree for the first time.

func _on_timer_timeout() -> void:
	ragdoll()

func ragdoll():
	var velocity_dir = global_basis * Vector3.MODEL_REAR
	$AnimationPlayer.active = false
	$hobogameready/Skeleton3D/PhysicalBoneSimulator3D.physical_bones_start_simulation()
	$"hobogameready/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone Chest".linear_velocity = (velocity_dir) * 2
	$"hobogameready/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone Spine".linear_velocity = (velocity_dir) * 2
	$"hobogameready/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone Hip".linear_velocity = (velocity_dir) * 2
	$"hobogameready/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone Neck".linear_velocity = (velocity_dir) * 3
func _on_ragdolltimer_timeout() -> void:
	#$hobo_goodrig/Skeleton3D/PhysicalBoneSimulator3D.influence = 0.1
	pass
