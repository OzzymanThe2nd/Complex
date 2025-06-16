extends SubViewportContainer
var debug_level = "res://Scenes/Levels/debug_level.tscn"
var first_level = "res://Scenes/Levels/first_area.tscn"
var loading : bool = true
var loading_destination 
var level_numbers = {
	0 : debug_level,
	1 : first_level
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Game.size.x = DisplayServer.screen_get_size()[0]
	$Game.size.y = DisplayServer.screen_get_size()[1]
	PlayerStatus.viewer = self
	change_level(PlayerStatus.current_level)

func change_level(new_level): 
	var level = level_numbers[new_level]
	ResourceLoader.load_threaded_request(level)
	loading_destination = level
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if loading:
		if ResourceLoader.THREAD_LOAD_LOADED:
			$Game.add_child((ResourceLoader.load_threaded_get(loading_destination)).instantiate())
			loading = false
