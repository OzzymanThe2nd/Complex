extends Node3D


func _input(event):
	if event is InputEventKey:
		if Input.is_action_just_pressed("quit"):
			if get_tree().paused == false:
				get_tree().paused = true
				$PauseMenu.visible = true
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				PlayerStatus.viewer.enable_filter(false)
			else:
				get_tree().paused = false
				$PauseMenu.visible = false
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				PlayerStatus.viewer.enable_filter()
