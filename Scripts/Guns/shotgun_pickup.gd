extends Node3D

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		PlayerStatus.shotgun_unlocked = true
		if body.current_weapon != null:
			if not body.current_weapon.is_in_group("shotgun"): body.queued = "shotgun"
			body.current_weapon.unequip()
		else:
			body.equip_shotgun()
		queue_free()
