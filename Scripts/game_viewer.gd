extends SubViewportContainer
var debug_level = "res://Scenes/Levels/debug_level.tscn"
var first_level = "res://Scenes/Levels/first_area.tscn"
var loading : bool = true
var loading_destination 
var level_numbers = {
	0 : debug_level,
	1 : first_level
}
var enabled 
@export var closeable : bool = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Game.size.x = DisplayServer.screen_get_size()[0]
	$Game.size.y = DisplayServer.screen_get_size()[1]
	PlayerStatus.viewer = self
	change_level(debug_level)
	enabled = get_material()

func change_level(new_level): 
	#var level = level_numbers[new_level]
	var level = debug_level
	ResourceLoader.load_threaded_request(level)
	loading_destination = level
	
func enable_filter(enable : bool = true):
	if enable == true:
		enabled.set_shader_parameter("enabled", true)
	else:
		enabled.set_shader_parameter("enabled", false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if loading:
		if ResourceLoader.THREAD_LOAD_LOADED:
			var loaded_zone = ResourceLoader.load_threaded_get(loading_destination).instantiate()
			$Game.add_child(loaded_zone)
			PlayerStatus.loaded_level = loaded_zone
			loading = false

func _input(event):
	if event is InputEventKey:
		if Input.is_action_just_pressed("quit") and closeable == true:
			if not loading and not PlayerStatus.keepplayer.pause_possible == false:
				if get_tree().paused == false:
					open_pause_menu()
				else:
					close_pause_menu()

func open_pause_menu():
	get_tree().paused = true
	PlayerStatus.keepplayer.make_guns_visible(false)
	$PauseMenu.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	PlayerStatus.viewer.enable_filter(false)

func close_pause_menu():
	get_tree().paused = false
	PlayerStatus.keepplayer.make_guns_visible()
	$PauseMenu.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	PlayerStatus.viewer.enable_filter()

func connect_player_dead(player):
	player.dead.connect(_on_player_dead)
func _on_player_dead():
	closeable = false
	open_pause_menu()
