extends Node3D

signal prisoners_changed

@onready var prisoner_statue: MeshInstance3D = $PrisonerStatue
var close_chums := []
var current_chum: int = 0
const default_overlay: Resource = preload("uid://2bkpq6hg3vot")
const overlays: Dictionary[int, Resource] = {17: preload("uid://c73d6kn6loqe7"),
											18: preload("uid://dnbueftif4745"),
											19: preload("uid://c4oeoyfla21gw"),
											20: preload("uid://blppf5iskmyrd"),}

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Chum:
		if body.chum_id in overlays.keys():
			close_chums.append(body.chum_id)
			current_chum = body.chum_id
			prisoner_statue.set_material_overlay(overlays[body.chum_id])
			prisoners_changed.emit()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Chum:
		if body.chum_id in overlays.keys():
			close_chums.erase(body.chum_id)
			if len(close_chums) == 0:
				current_chum = 0
				prisoner_statue.set_material_overlay(default_overlay)
			else:
				current_chum = close_chums[-1]
				prisoner_statue.set_material_overlay(overlays[current_chum])
			prisoners_changed.emit()


func _on_fly_zone_body_entered(body: Node3D) -> void:
	if body is Player:
		return
	var angle: float = Functions.angle_to_xz(self, body)
	var vel_2d: Vector2 = Vector2(sin(angle), cos(angle)) * 7.5
	
	body.velocity = Vector3(vel_2d.x, 25.0, vel_2d.y)
	body.is_launched = true
