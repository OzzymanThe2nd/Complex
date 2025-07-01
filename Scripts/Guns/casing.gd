extends RigidBody3D

func _ready() -> void:
	print(global_position)
	print($Marker3D.global_position)
	if global_position.x > $Marker3D.global_position.x:
		linear_velocity.x = global_position.x - $Marker3D.global_position.x
		print("first")
	else:
		linear_velocity.x = $Marker3D.global_position.x - global_position.x
		print("second")
	if global_position.z > $Marker3D.global_position.z:
		linear_velocity.z = global_position.z - $Marker3D.global_position.z
		print("third")
	else:
		linear_velocity.z = $Marker3D.global_position.z - global_position.z
		print("last")
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
