extends CharacterBody3D
class_name enemy_base
@export var health : float = 8
@export var casing = "res://Scenes/Guns/casing.tscn"
@export var muzzle_flash = "res://Scenes/Guns/muzzle_flash.tscn"
var travel_guide : Vector3 = Vector3(1, 1, 0) #Used for ragdoll
@export var player : Node3D
signal eject_casing
@export var aiming : bool = false
@export var dead : bool = false
@export var navi_agent : NavigationAgent3D
@export var SPEED : float = 0.3
@export var ROTATION_SPEED : float = 0.1
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
	var target = %ShootCast.get_collider()
	if target == player:
		player.take_damage(randi_range(31,34))
	var flash = load(muzzle_flash).instantiate()
	%FlashSpawner.add_child(flash)
	flash.follow_point = %FlashSpawner
	flash.position = %FlashSpawner.position

func spawn_casing(energy : bool = false):
	var spawned_casing = casing.instantiate()
	spawned_casing.gun_node = self
	if energy == false:
		spawned_casing.energy = false
	spawned_casing.global_position = %CasingSpawner.global_position
	spawned_casing.rotation = rotation
	%CasingSpawner.add_child(spawned_casing)

func move_to_player():
	velocity = Vector3.ZERO
	navi_agent.target_position = player.global_transform.origin
	var next_point = navi_agent.get_next_path_position()
	var new_velocity = (next_point - global_transform.origin).normalized() * SPEED
	velocity = new_velocity
	if aiming: $AnimationPlayer.play("aim_walk")
	else: $AnimationPlayer.play("walk")
	var global_pos = global_transform.origin
	var player_pos = player.global_transform.origin
	var wtransform = global_transform.looking_at(Vector3(player_pos.x,global_pos.y,player_pos.z),Vector3(0,1,0))
	var wrotation = Quaternion(global_transform.basis).slerp(Quaternion(wtransform.basis), ROTATION_SPEED)
	global_transform = Transform3D(Basis(wrotation), global_transform.origin)
	move_and_slide()

func _process(delta: float) -> void:
	if agro and not dead and $AnimationPlayer.current_animation != "aim_shoot":
		move_to_player()
