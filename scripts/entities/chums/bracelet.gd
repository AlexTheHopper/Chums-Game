extends Node3D

@onready var bracelet := $BraceletMesh

func _ready() -> void:
	bracelet.visible = false


func make_visible():
	bracelet.visible = true
	
func make_invisible():
	bracelet.visible = false
