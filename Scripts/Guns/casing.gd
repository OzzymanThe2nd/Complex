extends RigidBody3D

func _ready() -> void:
	if randi_range(0, 1) == 0:
		constant_torque.x = 0.01
		constant_torque.y = 0.01
		constant_torque.z = 0.01
	else:
		constant_torque.x = -0.01
		constant_torque.y = -0.01
		constant_torque.z = -0.01


func _on_area_3d_body_entered(body: Node3D) -> void:
	constant_torque.x = 0
	constant_torque.y = 0
	constant_torque.z = 0


func _on_timer_timeout() -> void:
	queue_free()
