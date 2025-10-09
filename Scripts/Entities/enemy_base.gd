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
@export var shootcast_default_target : Vector3 = Vector3(0, -1, 90)
@export var change_mesh_threshold : float = 2
@export var moving : bool = true
@export var busy : bool = false
var trail = "res://Scenes/Guns/projectile_trail.tscn"
var rotate_to : String
var DIRECTIONS = ["north", "south", "west", "east"]
var markers = []

func _ready() -> void:
	casing = load(casing)
	if player == null:
		player = PlayerStatus.keepplayer
	set_connections()
	$MovementTimer.wait_time = randf_range(8.0, 11.85)
	if not aiming:
		$AnimationPlayer.play("idle")
	if PlayerStatus.loaded_level is Node:
		if PlayerStatus.loaded_level.has_node("MarkerNorth"):
			markers.append(PlayerStatus.loaded_level.get_node("MarkerNorth"))
		if PlayerStatus.loaded_level.has_node("MarkerSouth"):
			markers.append(PlayerStatus.loaded_level.get_node("MarkerSouth"))
		if PlayerStatus.loaded_level.has_node("MarkerWest"):
			markers.append(PlayerStatus.loaded_level.get_node("MarkerWest"))
		if PlayerStatus.loaded_level.has_node("MarkerEast"):
			markers.append(PlayerStatus.loaded_level.get_node("MarkerEast"))
	else:
		markers.append($MarkerNorth)
		markers.append($MarkerSouth)
		markers.append($MarkerWest)
		markers.append($MarkerEast)
	trail = load(trail)

func take_damage(x : float, headshot : bool = false):
	agro = true
	health -= x
	agro_nearby()
	if health <= change_mesh_threshold:
		swap_to_damaged_mesh()
	if health <= 0 and dead == false:
		death()

func set_connections():
	pass

func death():
	pass

func ragdoll():
	pass

func trail_spawn():
	var new_trail = trail.instantiate()
	new_trail.position = %TrailSpawner.global_position
	%FlashSpawner.add_child(new_trail)
	new_trail.look_at(%TrailGuide.global_position)

func shoot():
	if aiming == true:
		$AnimationPlayer.play("aim_shoot")
		busy = true
		spawn_casing(true)
		%ShootCast.target_position = shootcast_default_target
		%ShootCast.target_position.x += randf_range(-5, 5)
		%ShootCast.target_position.y += randf_range(-10, 10)
		%ShootCast.target_position.z += randf_range(-5, 5)
		var target = %ShootCast.get_collider()
		if target == player:
			player.take_damage(randi_range(31,34))
		var flash = load(muzzle_flash).instantiate()
		trail_spawn()
		%FlashSpawner.add_child(flash)
		flash.follow_point = %FlashSpawner
		flash.position = %FlashSpawner.position
	else:
		raise_aim()

func spawn_casing(energy : bool = false):
	var spawned_casing = casing.instantiate()
	spawned_casing.gun_node = self
	if energy == false:
		spawned_casing.energy = false
	spawned_casing.global_position = %CasingSpawner.global_position
	spawned_casing.rotation = rotation
	%CasingSpawner.add_child(spawned_casing)

func swap_to_damaged_mesh():
	pass

func agro_nearby():
	for enemy in $AgroNearby.get_overlapping_bodies():
		if enemy.is_in_group("agroable_enemy"):
			enemy.agro = true

func move_to_player():
	velocity = Vector3.ZERO
	navi_agent.target_position = player.global_transform.origin
	var next_point = navi_agent.get_next_path_position()
	var new_velocity = (next_point - global_transform.origin).normalized() * SPEED
	velocity = new_velocity
	if aiming: $AnimationPlayer.play("aim_walk")
	else: $AnimationPlayer.play("walk")
	turn_to_player()
	move_and_slide()

func wander():
	var current_point
	if rotate_to == DIRECTIONS[0]:
		current_point = markers[0]
	elif rotate_to == DIRECTIONS[1]:
		current_point = markers[1]
	elif rotate_to == DIRECTIONS[2]:
		current_point = markers[2]
	else:
		current_point = markers[3]
	velocity = Vector3.ZERO
	navi_agent.target_position = current_point.global_transform.origin
	var next_point = navi_agent.get_next_path_position()
	var new_velocity = (next_point - global_transform.origin).normalized() * SPEED
	velocity = new_velocity
	var global_pos = global_transform.origin
	var point_pos = current_point.global_transform.origin
	var wtransform = global_transform.looking_at(Vector3(point_pos.x,global_pos.y,point_pos.z),Vector3(0,1,0))
	var wrotation = Quaternion(global_transform.basis).slerp(Quaternion(wtransform.basis), ROTATION_SPEED)
	global_transform = Transform3D(Basis(wrotation), global_transform.origin)
	if aiming: $AnimationPlayer.play("aim_walk")
	else: $AnimationPlayer.play("walk")
	move_and_slide()


func idle():
	$AnimationPlayer.play("idle")

func raise_aim():
	if not aiming:
		moving = false
		$AnimationPlayer.play("aiming")

func _process(delta: float) -> void:
	if agro and not dead and busy == false and moving:
		move_to_player()
	elif agro and not dead and busy == false:
		turn_to_player()
	elif not agro and moving:
		wander()
	elif not aiming:
		idle()

func turn_to_player():
	var global_pos = global_transform.origin
	var player_pos = player.global_transform.origin
	var wtransform = global_transform.looking_at(Vector3(player_pos.x,global_pos.y,player_pos.z),Vector3(0,1,0))
	var wrotation = Quaternion(global_transform.basis).slerp(Quaternion(wtransform.basis), ROTATION_SPEED)
	global_transform = Transform3D(Basis(wrotation), global_transform.origin)

func _on_despawn_timer_timeout() -> void:
	queue_free()

func _on_detect_player_body_entered(body: Node3D) -> void:
	agro = true
	raise_aim()

func _on_movement_timer_timeout() -> void:
	if moving == true:
		moving = false
	else:
		moving = true
	rotate_to = DIRECTIONS[randi_range(0,3)]

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "aiming":
		busy = false
		aiming = true
	elif anim_name == "aim_shoot":
		busy = false
