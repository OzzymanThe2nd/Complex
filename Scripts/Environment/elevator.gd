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

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	busy = false
