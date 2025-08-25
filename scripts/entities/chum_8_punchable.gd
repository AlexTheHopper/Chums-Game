extends Area3D

var room_particles := {"lobby": preload("res://particles/seeker_room_lobby.tscn"),
						"room": preload("res://particles/seeker_room_room.tscn"),
						"fountain": preload("res://particles/seeker_room_fountain.tscn"),
						"void": preload("res://particles/seeker_room_void.tscn"),
						"statue": preload("res://particles/seeker_room_statue.tscn"),
						"upgrade": preload("res://particles/seeker_room_upgrade.tscn"),
						}
var target_room_types := ["lobby", "room", "fountain", "void", "upgrade", "statue"]


func _on_smack_zone_area_entered(area: Area3D) -> void:
	if area.owner is Player:
		target_room_types.append(target_room_types.pop_front())
		show_target_type()

func show_target_type():
	var particle_instance = room_particles[target_room_types[0]].instantiate()
	$Particles.add_child(particle_instance)
