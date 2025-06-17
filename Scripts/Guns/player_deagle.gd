extends Node3D
var player : Node3D
var default_cast_rot : Vector3 
var y_spread : float = 0.0
var x_spread :float = 0.0
@export var shootable : bool = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = PlayerStatus.keepplayer
	default_cast_rot = %ShootCast.rotation
	y_spread = %ShootCast.rotation.y
	x_spread = %ShootCast.rotation.x

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	%ShootCast.rotation.y = lerp(%ShootCast.rotation.y, y_spread, 0.035)
	%ShootCast.rotation.x = lerp(%ShootCast.rotation.x, x_spread, 0.035)
		

func shoot():
	if shootable:
		shootable = false
		y_spread += %ShootCast.rotation.y + randf_range(-0.5, 0.5)
		x_spread += %ShootCast.rotation.x + randf_range(-0.4, -0.7)
		y_spread = clamp(y_spread, -0.5, 0.5)
		x_spread = clamp(x_spread, -0.5, 0.5)
		print(y_spread)
		#print(x_spread)
		if $AnimationPlayer.current_animation == "shoot": $AnimationPlayer.stop()
		$AnimationPlayer.play("shoot")
		$ShotCooldown.start()


func _on_shot_cooldown_timeout() -> void:
	y_spread = default_cast_rot.y
	x_spread = default_cast_rot.x


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "shoot":
		shootable = true
