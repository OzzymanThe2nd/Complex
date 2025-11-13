extends Node3D
@export var driving : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if driving:
		$AnimationPlayer.play("drive")
		$driving_path.play("driving_path")

# Called every frame. 'delta' is the elapsed time since the previous frame.
