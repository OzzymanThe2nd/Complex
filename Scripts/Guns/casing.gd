extends RigidBody3D
class_name casing
var energy : bool = true
var gun_node : Node3D
@export var travel_guide : Vector3 = Vector3(1, 1, 0) #Basis of where casing will actually fly
@export var vertical_velocity : float = 3.0

func _ready() -> void:
	if energy:
		var velocity_dir = gun_node.global_basis * Vector3.RIGHT
		linear_velocity = travel_guide * velocity_dir
		linear_velocity.y = vertical_velocity
		#if global_position.x > $Marker3D.global_position.x:
			#linear_velocity.x = global_position.x - $Marker3D.global_position.x
		#else:
			#linear_velocity.x = $Marker3D.global_position.x - global_position.x
		#if global_position.z > $Marker3D.global_position.z:
			#linear_velocity.z = global_position.z - $Marker3D.global_position.z
		#else:
			#linear_velocity.z = $Marker3D.global_position.z - global_position.z
		if randi_range(0, 1) == 0:
			constant_torque.x = 0.01
			constant_torque.y = 0.01
			constant_torque.z = 0.01
		else:
			constant_torque.x = -0.01
			constant_torque.y = -0.01
			constant_torque.z = -0.01
	else:
		linear_velocity.y = 0


func _on_area_3d_body_entered(body: Node3D) -> void:
	constant_torque.x = 0
	constant_torque.y = 0
	constant_torque.z = 0


func _on_timer_timeout() -> void:
	queue_free()
