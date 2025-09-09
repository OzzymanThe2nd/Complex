extends enemy_base

# Called when the node enters the scene tree for the first time.

func _on_timer_timeout() -> void:
	shoot()

func _on_ragdolltimer_timeout() -> void:
	#$hobo_goodrig/Skeleton3D/PhysicalBoneSimulator3D.influence = 0.1
	pass
