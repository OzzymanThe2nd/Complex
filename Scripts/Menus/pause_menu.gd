extends Control
var title_screen = "res://Scenes/Menus/title.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_close_pressed() -> void:
	get_tree().change_scene_to_packed(load(title_screen))

func _on_retry_pressed() -> void:
	get_tree().paused = false
	visible = false
	PlayerStatus.level_change(PlayerStatus.loaded_level.scene_file_path)
