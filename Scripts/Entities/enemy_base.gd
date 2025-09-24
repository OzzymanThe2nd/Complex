extends CharacterBody3D
class_name enemy_base
@export var health : float = 8
@export var casing = "res://Scenes/Guns/casing.tscn"
var travel_guide : Vector3 = Vector3(1, 1, 0) #Used for ragdoll
@export var player : Node3D
signal eject_casing
@export var aiming : bool = false
@export var dead : bool = false
@export var navi_agent : NavigationAgent3D
@export var SPEED : float = 0.01
@export var agro : bool = true

func _ready() -> void:
	casing = load(casing)
	if player == null:
		player = PlayerStatus.keepplayer

func take_damage(x : float, headshot : bool = false):
	health -= x
	if health <= 0 and dead == false:
		death()

func death():
	pass

func ragdoll():
	pass

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
	if agro:
		velocity = Vector3.ZERO
		navi_agent.target_position = player.global_transform.origin
		var next_point = navi_agent.get_next_path_position()
		var new_velocity = (next_point - global_transform.origin).normalized() * SPEED
		velocity = new_velocity
		move_and_slide()
		#Some collision issue here fucks with things
