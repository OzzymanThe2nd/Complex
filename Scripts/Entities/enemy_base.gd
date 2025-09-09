extends CharacterBody3D
class_name enemy_base
@export var casing = "res://Scenes/Guns/casing.tscn"
signal eject_casing
@export var aiming : bool = false

func _ready() -> void:
	casing = load(casing)

func shoot():
	spawn_casing(true)
	if aiming == true:
		$AnimationPlayer.play("aim_shoot")

func spawn_casing(energy : bool = false):
	var spawned_casing = casing.instantiate()
	spawned_casing.gun_node = self
	if energy == false:
		spawned_casing.energy = false
	spawned_casing.global_position = %CasingSpawner.global_position
	spawned_casing.rotation = rotation
	%CasingSpawner.add_child(spawned_casing)

func _process(delta: float) -> void:
	pass
