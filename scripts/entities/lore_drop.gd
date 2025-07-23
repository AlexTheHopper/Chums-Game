extends Node3D

@onready var text_popup_scene := load("res://scenes/entities/text_popup.tscn")
@onready var popup: Node3D = $Popup


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		popup.add_child(text_popup_scene.instantiate())


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		for text_popup in popup.get_children():
			text_popup.remove()
