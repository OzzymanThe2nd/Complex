extends Control
var title_screen = "res://Scenes/Menus/title.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#set_size(DisplayServer.screen_get_size())
	#set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	$TextureRect.size.y = DisplayServer.screen_get_size().y

func _on_close_pressed() -> void:
	get_tree().change_scene_to_packed(load(title_screen))

func _on_retry_pressed() -> void:
	get_tree().paused = false
	visible = false
	PlayerStatus.level_change(PlayerStatus.loaded_level.scene_file_path)
