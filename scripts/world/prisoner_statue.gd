extends Node3D

@onready var prisoner_statue: MeshInstance3D = $PrisonerStatue
var close_chums := []
const default_overlay: Resource = preload("uid://2bkpq6hg3vot")
const overlays: Dictionary[int, Resource] = {17: preload("uid://c73d6kn6loqe7"),
											18: preload("uid://dnbueftif4745"),
											19: preload("uid://c4oeoyfla21gw"),
											20: preload("uid://blppf5iskmyrd"),}

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Chum:
		if body.chum_id in overlays.keys():
			close_chums.append(body.chum_id)
			prisoner_statue.set_material_overlay(overlays[body.chum_id])


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Chum:
		if body.chum_id in overlays.keys():
			close_chums.erase(body.chum_id)
			if len(close_chums) == 0:
				prisoner_statue.set_material_overlay(default_overlay)
			else:
				prisoner_statue.set_material_overlay(overlays[close_chums[-1]])
