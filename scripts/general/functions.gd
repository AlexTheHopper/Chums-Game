extends Node


func distance_between(body1, body2) -> float:
	return (body1.global_position.distance_to(body2.global_position))
	
func distance_squared(body1, body2) -> float:
	return (body1.global_position.distance_squared_to(body2.global_position))
	
func vector_to_normalized(body1, body2) -> Vector3:
	var to_return = body2.global_position - body1.global_position
	to_return = to_return.normalized()
	return (to_return)
	
func vector_to(body1, body2) -> Vector3:
	return body2.global_position - body1.global_position
	
func angle_to_xz(body1, body2) -> float:
	var dir = vector_to_normalized(body1, body2)
	var dir_plane = Vector2(dir[2], dir[0])
	return dir_plane.angle()
	
func get_closest_chum_in_group(chum, group):
	var members = get_tree().get_nodes_in_group(group)
	if len(members) > 0:
		var closest = members[0]
		var distance = distance_squared(chum, closest)
		for member in members:
			if distance_squared(chum, member) < distance:
				closest = member
				distance = distance_squared(chum, closest)
				
		return closest
	else:
		return null
		
func map_range(value: float, range1: Vector2, range2: Vector2) -> float:
	if value <= range1[0]:
		return range2[0]
	elif value >= range1[1]:
		return range2[1]
	elif range1[0] == range1[1]:
		return range2[1]

	var percentage = (value - range1[0]) / (range1[1] - range1[0])
	return range2[0] + percentage * (range2[1] - range2[0])
	
#Goes up tree until a node is in a group, returns that group name as str
func get_parent_group(node):
	if len(node.get_groups()) > 0:
		return node.get_groups()[0]
	elif node.get_parent():
		return get_parent_group(node.get_parent())
	else:
		return false
		
func dict_to_grid_coord(vector: Vector2, size: int) -> Vector2:
	return Vector2(int(vector.x + size), int(vector.y + size))

func grid_to_dict_coord(vector: Vector2, size: int) -> Vector2:
	return Vector2(int(vector.x - size), int(vector.y - size))
		
func astar2d(map: Array, goal: int, only_activated := false):
	var directions := [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]

	var size: int = map.size()
	
	var dir_map := {}
	var visited := []
	var queue := []
	var goal_in_map := false

	for x in range(size):
		visited.append([])
		for y in range(size):
			
			if map[x][y] == goal and (not only_activated or not Global.world_map[Vector2i(x, y)]["activated"]):
				visited[x].append(true)
				queue.append(Vector2i(x, y))
				dir_map[Vector2i(x, y)] = Vector2i(0, 0)
				goal_in_map = true
			else:
				visited[x].append(false)
	#If it doesnt exist, count all rooms as dont go anywhere
	if not goal_in_map:
		for x in range(size):
			for y in range(size):
				dir_map[Vector2i(x, y)] = Vector2i(0, 0)
		return dir_map
	
	while queue.size() > 0:
		var current = queue.pop_front()
		
		for d in directions:
			var n = current + d
			
			if n.x not in [-1, size] and n.y not in [-1, size]:
				if map[n.x][n.y] != 0 and not visited[n.x][n.y]:
					visited[n.x][n.y] = true
					queue.append(n)
					dir_map[n] = -d
	return dir_map
			
			
