extends Node
var warp_to = null
var keepplayer
var viewer
var loading_new_game : bool = false
var current_level : int = 0
const MAX_HEALTH = 100
var player_health : int = 100
var loaded_level

func level_change(level, warp_position : Vector3):
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
		viewer.get_node("Game").add_child((ResourceLoader.load_threaded_get(load_level)).instantiate())
		#loading_image_clear()
