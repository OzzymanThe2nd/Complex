extends Node3D


func _on_elevator_shake_timeout() -> void:
	$Player.rumbling = false
	$Player.move_locked = false
	$Player.cam_locked = false
