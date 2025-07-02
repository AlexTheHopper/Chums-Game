extends Node3D
@onready var cages: Node3D = $cages

func _ready() -> void:
	Global.current_room_node = self
	pass
