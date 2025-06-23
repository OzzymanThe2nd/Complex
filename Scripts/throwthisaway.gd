extends Node3D
signal unequiped

# Called when the node enters the scene tree for the first time.
func unequip():
	unequiped.emit()
	queue_free()
