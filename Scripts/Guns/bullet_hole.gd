extends Decal
var normal : Vector3
var hit_pos : Vector3 = Vector3(0,0,0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_transform.origin = hit_pos
	look_at(hit_pos + normal, Vector3.UP)
	$GPUParticles3D.emitting = true
	print(rotation_degrees)
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
#

func _on_timer_timeout() -> void:
	queue_free()
