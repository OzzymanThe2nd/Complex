extends enemy_base

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#$hoboattempt/rig/Skeleton3D/PhysicalBoneSimulator3D.active = true
	pass

func _on_timer_timeout() -> void:
	$AnimationPlayer.active = false
	#$hobo_goodrig/Skeleton3D/PhysicalBoneSimulator3D.physical_bones_start_simulation()
	$RagdollTimer.start()

func _on_ragdolltimer_timeout() -> void:
	#$hobo_goodrig/Skeleton3D/PhysicalBoneSimulator3D.influence = 0.1
	pass
