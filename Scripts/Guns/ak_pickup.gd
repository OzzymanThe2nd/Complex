extends Node3D


## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
#

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		PlayerStatus.rifle_unlocked = true
		if body.current_weapon != null:
			if not body.current_weapon.is_in_group("rifle"): body.queued = "rifle"
			body.current_weapon.unequip()
		else:
			body.equip_rifle()
		queue_free()
