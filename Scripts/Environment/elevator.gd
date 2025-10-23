extends Node3D
@export var shut : bool = true
@export var busy : bool = false
@export var destination : String = "res://Scenes/Levels/debug_level.tscn"
@export var player_look_to : Vector3 = Vector3(-2,180,0)
@export var set_step_on_exit : String = "concrete"
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	if shut == false:
		open()
	else:
		PlayerStatus.viewer.play_elevator_move_stop()

func open():
	$AnimationPlayer.play("opening")

func interact():
	if shut and not busy:
		shut = false
		busy = true
		$AnimationPlayer.play("opening_shut_lights")
	if not shut and not busy:
		shut = true
		busy = true
		$AnimationPlayer.play("closing")
		var player = PlayerStatus.keepplayer
		player.pause_possible = false
		if player.current_weapon == null:
			player.look_to_dir(player_look_to)
			player.move_to_pos($PlayerMoveSpot.global_position)
		else:
			player.current_weapon.unequip()
			await player.current_weapon.unequiped
			player.look_to_dir(player_look_to)
			player.move_to_pos($PlayerMoveSpot.global_position)
		$LevelTransitionTimer.start()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	var player = PlayerStatus.keepplayer
	if anim_name == "closing":
		player.rumbling = true
		PlayerStatus.viewer.play_elevator_move()


func _on_level_transition_timer_timeout() -> void:
	PlayerStatus.level_change(destination)


func _on_set_elevator_footstep_body_entered(body: Node3D) -> void:
	body.step_sound_type = "elevator"

func _on_set_footstep_back_body_entered(body: Node3D) -> void:
	body.step_sound_type = set_step_on_exit
