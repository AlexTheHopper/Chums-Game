extends Area3D

@onready var quality_popup_scene := load("res://scenes/entities/quality_popup.tscn")
@onready var chum := owner
@onready var shape := $CollisionShape3D

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		#Add chum to close chums if not already in:
		if chum not in ChumsManager.close_chums:
			ChumsManager.close_chums.append(chum)
		
		chum.player_is_near = true
		#Display quality popup if no other close chums and doesnt already have it
		if ChumsManager.close_chums[0] == chum and not chum.has_quality_popup and not Global.in_battle and chum.is_on_floor():
			var popup = quality_popup_scene.instantiate()
			chum.add_child(popup)
			popup.global_position += Vector3(0, 2, 0)

func _on_body_exited(body: Node3D) -> void:
	if body is Player:		
		#Remove quality popup if it exists
		for popup in chum.get_children():
			if popup is Quality_Popup:
				popup.remove()
		#chum.has_quality_popup = false
				
		#Remove self from close chums:
		ChumsManager.close_chums.erase(chum)
		
		#Update other close chums to open quality popup:
		for close_chum in ChumsManager.close_chums:
			if close_chum != chum:
				close_chum.interaction_area._on_body_entered(get_tree().get_first_node_in_group("Player"))

		chum.player_is_near = false
