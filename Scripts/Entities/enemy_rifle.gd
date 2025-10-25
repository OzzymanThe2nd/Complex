extends enemy_base
@export var full_auto : bool = false
var shot_burst_remaining : int = 0
@export var shot_burst_range : Array = [2, 4]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_timer_timeout() -> void:
	if agro and not dead and $BurstCooldown.time_left == 0:
		if shot_burst_remaining == 0:
			shot_burst_remaining = randi_range(shot_burst_range[0], shot_burst_range[1])
		if $DetectPlayer.overlaps_body(player):
			shoot()
			shot_burst_remaining -= 1
			if shot_burst_remaining == 0:
				$BurstCooldown.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
