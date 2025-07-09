extends weapon


# Called when the node enters the scene tree for the first time.
func set_current_bullets():
	current_bullets = PlayerStatus.bullets_in_deagle

func set_connections():
	$ShotCooldown.timeout.connect(_on_shot_cooldown_timeout)
	$AnimationPlayer.animation_finished.connect(_on_animation_player_animation_finished)

func check_jam_state():
	if PlayerStatus.deagle_jammed == true: jammed = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		PlayerStatus.deagle_jammed = jammed
		PlayerStatus.bullets_in_deagle = current_bullets
