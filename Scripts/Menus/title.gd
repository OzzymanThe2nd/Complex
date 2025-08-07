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
var active_button = null
@export var set_controls : Array[String] = []
@onready var settings_ui : Array = [$MouseSens, $MasterVolume, $GunVolume, $WorldVolume, $VoiceVolume, $FOVSlider, $Control_Bindings, $Back]
@onready var buttons : Array = [$Control_Bindings/interact/Button, $Control_Bindings/move_jump/Button, $Control_Bindings/lean_left/Button, $Control_Bindings/lean_right/Button, $Control_Bindings/move_forw/Button, $Control_Bindings/move_left/Button, $Control_Bindings/move_right/Button, $Control_Bindings/move_back/Button, $"Control_Bindings/1/Button", $"Control_Bindings/2/Button", $"Control_Bindings/3/Button", $"Control_Bindings/0/Button", $Control_Bindings/reload/Button]
var default_values = {"interact" : "F",
	"move_jump" : "Space",
	"lean_left" : "Q",
	"lean_right" : "E",
	"move_forw" : "W",
	"move_left" : "A",
	"move_right" : "D",
	"move_back" : "S",
	"1" : "1",
	"2" : "2",
	"3" : "3",
	"0" : "0",
	"reload" : "R"}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in wobbling_elements:
		main_title_start_positions.append(i.position)
	$Game.size.x = DisplayServer.screen_get_size()[0]
	$Game.size.y = DisplayServer.screen_get_size()[1]
	var config = ConfigFile.new()
	var conf = config.load("user://settings.cfg")
	if conf != OK:
		set_default_config(config)
	else:
		for bind in set_controls:
			var new_bind = InputEventKey.new()
			new_bind.keycode = OS.find_keycode_from_string(config.get_value("Bind", bind))
			InputMap.action_erase_events(bind)
			InputMap.action_add_event(bind, new_bind)
		update_button_text()

func set_default_config(config : ConfigFile):
	#config.set_value("Control", "crouchtoggle", false)
	config.set_value("Control", "mouse_sens", 0.0035)
	config.set_value("Control", "fov", 90)
	config.set_value("Sound", "vol", 100)
	config.set_value("Sound", "worldvol", 100)
	config.set_value("Sound", "gunvol", 100)
	config.set_value("Sound", "voicevol", 100)
	for bind in set_controls:
		config.set_value("Bind", bind, default_values[bind])
	for bind in set_controls:
		var new_bind = InputEventKey.new()
		new_bind.keycode = OS.find_keycode_from_string(config.get_value("Bind", bind))
		InputMap.action_erase_events(bind)
		InputMap.action_add_event(bind, new_bind)
	config.save("user://settings.cfg")
	update_button_text()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if rumble_x_start == 0:
		rumble_x_start = %MenuCam.rotation_degrees.x
	if rumble_y_start == 0:
		rumble_y_start = %MenuCam.rotation_degrees.y
	if snapped(%MenuCam.rotation_degrees.x, 0.01) == snapped(rumble_x_start + rumble_x_destination, 0.01) or rumble_x_destination == 0:
		rumble_x_destination = randf_range(-0.1, 0.1)
	if snapped(%MenuCam.rotation_degrees.y, 0.01) == snapped(rumble_y_start + rumble_y_destination, 0.01) or rumble_y_destination == 0:
		rumble_y_destination = randf_range(-0.1, 0.1)
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

func update_settings_text():
	$FOVSlider/FOVValue.text = str($FOVSlider.value)
	$VoiceVolume/VoiceVolumeValue.text = str($VoiceVolume.value)
	$WorldVolume/WorldVolumeValue.text = str($WorldVolume.value)
	$GunVolume/GunVolumeValue.text = str($GunVolume.value)
	$MasterVolume/MasterVolumeValue.text = str($MasterVolume.value)
	$MouseSens/MouseSensValue.text = str($MouseSens.value)

func swap_screen(opening_settings: bool = true):
	if opening_settings:
		for i in hide_in_options:
			i.visible = false
		update_settings_text()
		for i in settings_ui:
			i.visible = true
		options_open = true
	else:
		active_button = null
		for i in hide_in_options:
			i.visible = true
		for i in settings_ui:
			i.visible = false
		save_options()
		options_open = false

func update_button_text():
	var config = ConfigFile.new()
	var conf = config.load("user://settings.cfg")
	for i in buttons:
		var action = InputMap.action_get_events(i.get_parent().name)
		action = action[0].as_text()
		if action.ends_with(" (Physical)"):
			var delete_from = action.find(" (Physical)")
			action = action.erase(delete_from, 11)
		i.text = action
	$MouseSens.value = config.get_value("Control","mouse_sens") * 10000
	$MasterVolume.value = config.get_value("Sound","vol")
	$WorldVolume.value = config.get_value("Sound","worldvol")
	$GunVolume.value = config.get_value("Sound","gunvol")
	$VoiceVolume.value = config.get_value("Sound","voicevol")
	$FOVSlider.value = config.get_value("Control","fov")

func save_options():
	var config = ConfigFile.new()
	var conf = config.load("user://settings.cfg")
	config.set_value("Control", "mouse_sens", $MouseSens.value / 10000)
	config.set_value("Sound", "vol", $MasterVolume.value)
	config.set_value("Sound", "worldvol", $WorldVolume.value)
	config.set_value("Sound", "gunvol", $GunVolume.value)
	config.set_value("Sound", "voicevol", $VoiceVolume.value)
	#config.set_value("Bind", "interact", InputMap.action_get_events("interact")[0])
	config.save("user://settings.cfg")

func _input(event):
	if event is InputEventKey:
		if Input.is_action_just_pressed("quit"):
			if active_button != null:
				active_button = null
			elif options_open:
				swap_screen(false)
			else:
				get_tree().quit()
		if active_button != null:
			var control_helper : Dictionary = {}
			for action in InputMap.get_actions():
				for event_act in InputMap.action_get_events(action):
					control_helper[event_act.as_text()] = action
			if control_helper.keys().has(event.as_text()):
				InputMap.action_erase_events(control_helper[event.as_text()])
			InputMap.action_erase_events(active_button.get_parent().name)
			InputMap.action_add_event(active_button.get_parent().name, event)
			active_button.text = event.as_text()
			var config = ConfigFile.new()
			var conf = config.load("user://settings.cfg")
			config.set_value("Bind", active_button.get_parent().name, event.as_text())
			config.save("user://settings.cfg")
			active_button = null

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

func _on_interact_pressed() -> void:
	active_button = $Control_Bindings/interact/Button

func _on_move_jump_pressed() -> void:
	active_button = $Control_Bindings/move_jump/Button

func _on_lean_left_pressed() -> void:
	active_button = $Control_Bindings/lean_left/Button

func _on_lean_right_pressed() -> void:
	active_button = $Control_Bindings/lean_right/Button

func _on_move_forw_pressed() -> void:
	active_button = $Control_Bindings/move_forw/Button

func _on_move_left_pressed() -> void:
	active_button = $Control_Bindings/move_left/Button

func _on_move_right_pressed() -> void:
	active_button = $Control_Bindings/move_right/Button

func _on_move_back_pressed() -> void:
	active_button = $Control_Bindings/move_back/Button

func _on_1_pressed() -> void:
	active_button = $"Control_Bindings/1/Button"

func _on_2_pressed() -> void:
	active_button = $"Control_Bindings/2/Button"

func _on_3_pressed() -> void:
	active_button = $"Control_Bindings/3/Button"

func _on_0_pressed() -> void:
	active_button = $"Control_Bindings/0/Button"

func _on_reload_pressed() -> void:
	active_button = $Control_Bindings/reload/Button

func _on_back_pressed() -> void:
	if active_button != null:
		active_button = null
	swap_screen(false)

func _on_default_pressed() -> void:
	var config = ConfigFile.new()
	var conf = config.load("user://settings.cfg")
	set_default_config(config)
