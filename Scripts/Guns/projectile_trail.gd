extends Node3D
@export var SPEED : float = 3.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#global_scale(Vector3(1, 1, 1))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Area3D.position += (Vector3.FORWARD * SPEED)

func _on_area_3d_body_entered(body: Node3D) -> void:
	queue_free()

func _on_timer_timeout() -> void:
	queue_free()
