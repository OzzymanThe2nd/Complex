extends Node3D
@export var shut : bool = false
@export var busy : bool = false
# Called when the node enters the scene tree for the first time.
func interact():
	if shut and not busy:
		shut = false
		busy = true
		$AnimationPlayer.play("opening")
	if not shut and not busy:
		shut = true
		busy = true
		$AnimationPlayer.play("closing")
		var player = PlayerStatus.keepplayer
		player.look_to_dir(Vector3(-2, 180, 0))
		player.move_to_pos($PlayerMoveSpot.global_position)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	busy = false
