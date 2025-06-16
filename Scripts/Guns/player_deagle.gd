extends Node3D
var player : Node3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = PlayerStatus.keepplayer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#if player.velocity.x != 0 pr player.velocity.z != 0:
		
