extends enemy_base

# Called when the node enters the scene tree for the first time.

func _on_timer_timeout() -> void:
	$AnimationPlayer.active = false
	$hobogameready/Skeleton3D/PhysicalBoneSimulator3D.physical_bones_start_simulation()
func _on_ragdolltimer_timeout() -> void:
	#$hobo_goodrig/Skeleton3D/PhysicalBoneSimulator3D.influence = 0.1
	pass
