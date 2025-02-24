extends Node

var decorations : Dictionary

func _ready() -> void:
	decorations['streetlamp'] = preload("res://scenes/world/streetlamp.tscn")
