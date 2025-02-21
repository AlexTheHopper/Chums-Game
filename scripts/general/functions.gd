extends Node


func distance_between(body1, body2) -> float:
	return (body1.global_position.distance_to(body2.global_position))
	
func vector_to_normalized(body1, body2) -> Vector3:
	var to_return = body2.global_position - body1.global_position
	to_return = to_return.normalized()
	return (to_return)
	
func vector_to(body1, body2) -> Vector3:
	return body2.global_position - body1.global_position
	
func angle_to_xz(body1, body2) -> float:
	var dir = vector_to_normalized(body1, body2)
	var dir_plane = Vector2(dir[2], dir[0])
	return dir_plane.angle() + PI
	
func get_closest_chum_in_group(chum, group):
	var members = get_tree().get_nodes_in_group(group)
	if len(members) > 0:
		var closest = members[0]
		var distance = distance_between(chum, closest)
		for member in members:
			if distance_between(chum, member) < distance:
				closest = member
				distance = distance_between(chum, closest)
				
		return closest
	else:
		return null
