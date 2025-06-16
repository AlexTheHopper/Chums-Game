extends Node3D

var mesh_node: Node3D
var chum_id: int
var to_boss: Area3D

func _ready() -> void:
	mesh_node = $MeshNode
	to_boss = $RoomChanger
	
	chum_id = Global.world_map[Global.room_location]["statue_id"]
	mesh_node.add_child(load("res://assets/world/chum_statues/chum_%s_statue.tscn" % [chum_id]).instantiate())


func _on_fly_zone_body_entered(body: Node3D) -> void:
	if body is Chum:
		var angle: float = Functions.angle_to_xz(self, body)
		var vel_2d: Vector2 = Vector2(sin(angle), cos(angle)) * 7.5
		
		body.velocity = Vector3(vel_2d.x, 25.0, vel_2d.y)
		body.is_launched = true


func _on_detection_zone_body_entered(body: Node3D) -> void:
	if body is Chum:
		if body.chum_str == "chum%s" % [chum_id]:
			to_boss.active = true
			mesh_node.visible = false
			
			#Remove tiles to reveal room changer
			for x in [-1, 0, 1]:
				for y in [-1, 0, 1]:
					Global.current_room_node.grid_map.set_cell_item(Vector3(x, -1, y), -1, 0)
			
