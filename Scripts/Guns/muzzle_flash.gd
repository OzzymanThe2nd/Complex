extends GPUParticles3D
var follow_point

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	emitting = true
	print(position)
	print(global_position)

func _process(delta: float) -> void:
	if follow_point:
		self.position = follow_point.position

func _on_finished() -> void:
	queue_free()
