extends Node3D

#func _ready() -> void:
	#$Player.rumbling = true
	#$Player.cam_locked = true


func _on_elevator_shake_timeout() -> void:
	$Player.instant_cam_snap = false
	$Player.rumbling = false
	$Player.move_locked = false
	$Player.cam_locked = false
