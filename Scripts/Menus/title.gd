extends Control
var rumble_x_start : float
var rumble_y_start : float
var rumble_x_destination : float
var rumble_y_destination : float
var loading_path : String = "res://Scenes/game_viewer.tscn"
var loading : bool = false
@onready var hide_in_options: Array = [$Start, $Settings, $Close, $TextureRect]
var options_open : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Game.size.x = DisplayServer.screen_get_size()[0]
	$Game.size.y = DisplayServer.screen_get_size()[1]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if rumble_x_start == 0:
		rumble_x_start = %MenuCam.rotation_degrees.x
	if rumble_y_start == 0:
		rumble_y_start = %MenuCam.rotation_degrees.y
	if snapped(%MenuCam.rotation_degrees.x, 0.01) == snapped(rumble_x_start + rumble_x_destination, 0.01) or rumble_x_destination == 0:
		rumble_x_destination = randf_range(-0.1, 0.1)
		print(rumble_x_destination)
	if snapped(%MenuCam.rotation_degrees.y, 0.01) == snapped(rumble_y_start + rumble_y_destination, 0.01) or rumble_y_destination == 0:
		rumble_y_destination = randf_range(-0.1, 0.1)
		print(rumble_y_destination)
	%MenuCam.rotation_degrees.x = lerp(%MenuCam.rotation_degrees.x, rumble_x_start + rumble_x_destination, 0.05)
	%MenuCam.rotation_degrees.y = lerp(%MenuCam.rotation_degrees.y, rumble_y_start + rumble_y_destination, 0.05)
	if loading:
		if ResourceLoader.THREAD_LOAD_LOADED:
			loading = false
			get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(loading_path))


func _on_start_pressed() -> void:
	loading = true
	ResourceLoader.load_threaded_request(loading_path)

func _on_close_pressed() -> void:
	get_tree().quit()

func _on_settings_pressed() -> void:
	swap_screen(true)

func swap_screen(opening_settings: bool = true):
	if opening_settings:
		for i in hide_in_options:
			i.visible = false
		options_open = true
	else:
		for i in hide_in_options:
			i.visible = true
		options_open = false

func _input(event):
	if event is InputEventKey:
		if Input.is_action_just_pressed("quit"):
			if options_open:
				swap_screen(false)
			else:
				get_tree().quit()
