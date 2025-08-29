extends Node
var warp_to = null
var keepplayer
var viewer
var loading_new_game : bool = false
const MAX_HEALTH = 100
var player_health : int = 100
var loaded_level
var bullets_in_deagle : int = 8
var bullets_in_rifle : int = 30
var bullets_in_shotgun : int = 1
var deagle_jammed : bool = false
var rifle_jammed : bool = false
var shotgun_jammed : bool = false
var rifle_unlocked : bool = true
var shotgun_unlocked : bool = true
var pistol_recoil_level : int = 0
var rifle_recoil_level : int = 0
var shotgun_stunned : bool = false

func reset_to_default():
	player_health = 100
	bullets_in_deagle = 8
	deagle_jammed = false
	bullets_in_rifle = 30
	rifle_jammed = false
	bullets_in_shotgun = 1
	shotgun_jammed = false
	shotgun_stunned = false
	pistol_recoil_level = 0
	rifle_recoil_level = 0

func level_change(level, warp_position : Vector3 = Vector3(0,0,0)):
	var load_level = level
	warp_to = warp_position
	#loading_image_appear()
	await get_tree().process_frame
	ResourceLoader.load_threaded_request(load_level)
	if keepplayer != null: keepplayer.get_parent().queue_free()
	while ResourceLoader.load_threaded_get_status(load_level) != 3:
		pass
	if ResourceLoader.THREAD_LOAD_LOADED:
		#print(viewer.get_node("Game").get_children())
		#viewer.get_node("Game").get_children()[0].queue_free()
		#print(viewer.get_node("Game").get_children())
		var new_level = (ResourceLoader.load_threaded_get(load_level)).instantiate()
		loaded_level = new_level
		viewer.get_node("Game").add_child(new_level)
		for i in viewer.get_node("Game").get_children():
			if i != new_level:
				i.queue_free()
		#loading_image_clear()
