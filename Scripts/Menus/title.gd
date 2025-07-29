extends Control
var rumble_x_start : float
var rumble_y_start : float
var rumble_x_destination : float
var rumble_y_destination : float
var loading_path : String = "res://Scenes/game_viewer.tscn"
var loading : bool = false
@onready var hide_in_options : Array = [$Start, $Settings, $Close, $TextureRect, $Label]
@onready var wobbling_elements : Array = [$Start, $Settings, $Close]
var main_title_start_positions : Array
var options_open : bool = false
@onready var settings_ui : Array = [$MouseSens, $MasterVolume, $GunVolume, $WorldVolume, $VoiceVolume, $FOVSlider]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in wobbling_elements:
		main_title_start_positions.append(i.position)
	$Game.size.x = DisplayServer.screen_get_size()[0]
	$Game.size.y = DisplayServer.screen_get_size()[1]
	var config = ConfigFile.new()
	var conf = config.load("user://settings.cfg")
	if conf != OK:
		config.set_value("Control", "crouchtoggle", false)
		config.set_value("Control", "mouse_sens", 0.0035)
		config.set_value("Control", "fov", 90)
		config.set_value("Sound", "vol", 100)
		config.set_value("Sound", "worldvol", 100)
		config.set_value("Sound", "gunvol", 100)
		config.set_value("Sound", "voicevol", 100)
		config.save("user://settings.cfg")
	$MouseSens.value = config.get_value("Control","mouse_sens") * 10000
	$MasterVolume.value = config.get_value("Sound","vol")
	$WorldVolume.value = config.get_value("Sound","worldvol")
	$GunVolume.value = config.get_value("Sound","gunvol")
	$VoiceVolume.value = config.get_value("Sound","voicevol")
	$FOVSlider.value = config.get_value("Control","fov")


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
	for i in wobbling_elements:
		var start_position = main_title_start_positions.find(i)
		var start_x = main_title_start_positions[start_position].x
		var start_y = main_title_start_positions[start_position].y
		if i.position.x + (rumble_x_destination / 5) < (start_x + 8) and i.position.x + (rumble_x_destination / 5) > (start_x - 8):
			i.position.x = i.position.x + (rumble_x_destination / 5)
		if i.position.y + (rumble_y_destination / 5) < (start_y + 8) and i.position.y + (rumble_y_destination / 5) > (start_y - 8):
			i.position.y = i.position.y + (rumble_y_destination / 5)
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
		$FOVSlider/FOVValue.text = str($FOVSlider.value)
		for i in settings_ui:
			i.visible = true
		options_open = true
	else:
		for i in hide_in_options:
			i.visible = true
		for i in settings_ui:
			i.visible = false
		save_options()
		options_open = false

func save_options():
	var config = ConfigFile.new()
	var conf = config.load("user://settings.cfg")
	config.set_value("Control", "mouse_sens", $MouseSens.value / 10000)
	config.set_value("Sound", "vol", $MasterVolume.value)
	config.set_value("Sound", "worldvol", $WorldVolume.value)
	config.set_value("Sound", "gunvol", $GunVolume.value)
	config.set_value("Sound", "voicevol", $VoiceVolume.value)
	config.save("user://settings.cfg")

func _input(event):
	if event is InputEventKey:
		if Input.is_action_just_pressed("quit"):
			if options_open:
				swap_screen(false)
			else:
				get_tree().quit()


func _on_mouse_sens_value_changed(value: float) -> void:
	$MouseSens/MouseSensValue.text = str(value)

func _on_master_volume_value_changed(value: float) -> void:
	$MasterVolume/MasterVolumeValue.text = str(value)

func _on_gun_volume_value_changed(value: float) -> void:
	$GunVolume/GunVolumeValue.text = str(value)

func _on_world_volume_value_changed(value: float) -> void:
	$WorldVolume/WorldVolumeValue.text = str(value)

func _on_voice_volume_value_changed(value: float) -> void:
	$VoiceVolume/VoiceVolumeValue.text = str(value)

func _on_fov_slider_value_changed(value: float) -> void:
	$FOVSlider/FOVValue.text = str(value)
