extends Node3D

var chum_id: int
var flower_chum_ids := [6, 7, 16, 26, 27]
var active := false
var chum_statue_node: Node3D
var change_particles := {
	6: load("res://particles/spawn_particles_world1.tscn"),
	7: load("res://particles/spawn_particles_world1.tscn"),
	26: load("res://particles/spawn_particles_world2.tscn"),
	16: load("res://particles/spawn_particles_world3.tscn"),
	27: load("res://particles/spawn_particles_world4.tscn"),
}
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var mesh_node: Node3D = $MeshNode
@onready var to_boss: room_changer_to_boss = $RoomChanger
@onready var room_changer_zone: room_changer_to_boss = $RoomChanger

@onready var mesh_colours := {
	0:  Color.from_rgba8(51, 51, 51, 255),
	1:  Color.from_rgba8(60, 79, 56, 255),
	2:  Color.from_rgba8(135, 135, 135, 255),
	3:  Color.from_rgba8(99, 77, 74, 255),
	4:  Color.from_rgba8(44, 49, 77, 255),
}

func _ready() -> void:
	chum_id = Global.world_map[Global.room_location]["room_specific_id"]
	var chum_statue = load("res://assets/world/chum_statues/chum_%s_statue.tscn" % [chum_id]).instantiate()
	chum_statue_node = chum_statue
	if chum_id not in flower_chum_ids:
		set_statue_colour(ChumsManager.chums_list[chum_id]["destination_world"])
	mesh_node.add_child(chum_statue)
	
	if Global.world_map[Global.room_location]["activated"]:
		mesh_node.visible = false
		animation_player.speed_scale = 10.0
		animation_player.play("activate")
		open_door()
	
	check_for_pattern()

func _on_timer_timeout() -> void:
	active = true

func set_statue_colour(dest_n: int) -> void:
	if not chum_statue_node:
		return
	for child in chum_statue_node.get_children():
		if child is MeshInstance3D:
			child.mesh.surface_get_material(0).albedo_color = mesh_colours[dest_n]

func _on_fly_zone_body_entered(body: Node3D) -> void:
	if body is Chum:
		var angle: float = Functions.angle_to_xz(self, body)
		var vel_2d: Vector2 = Vector2(sin(angle), cos(angle)) * 7.5
		
		body.velocity = Vector3(vel_2d.x, 25.0, vel_2d.y)
		body.move_and_slide()
		body.is_launched = true


func _on_detection_zone_body_entered(body: Node3D) -> void:
	if body is Chum and active:
		#Check for flower match:
		if body.chum_id in flower_chum_ids and chum_id in flower_chum_ids:
			chum_id = body.chum_id
			Global.world_map[Global.room_location]["room_specific_id"] = body.chum_id
			set_statue_colour(ChumsManager.chums_list[chum_id]["destination_world"])
			room_changer_zone.set_chum_id(chum_id)
			
			if chum_id in change_particles.keys():
				mesh_node.add_child(change_particles[chum_id].instantiate())

		if body.chum_id == chum_id:
			animation_player.play("activate")
			open_door()

func open_door() -> void:
	to_boss.active = true
	active = false
	#Remove tiles to reveal room changer
	for x in [-1, 0, 1]:
		for y in [-1, 0, 1]:
			Global.current_room_node.grid_map.set_cell_item(Vector3(x, -1, y), -1, 0)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "activate":
		mesh_node.visible = false
		Global.world_map[Global.room_location]["activated"] = true
		Global.world_map_guide["statue"] = Functions.astar2d(Global.world_grid, 5, true)

func do_shake() -> void:
	if not Global.world_map[Global.room_location]["activated"]:
		get_tree().get_first_node_in_group("Camera").trigger_shake(2.5, 2.5)
		AudioManager.controller_shake(randf_range(0.6, 0.9), 0.0, randf_range(0.5, 0.75))
		AudioManager.create_3d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_STATUE_SHAKE)

func check_for_pattern() -> void:
	var pattern_num = Global.world_map[Global.room_location]["to_spawn"]
	if pattern_num >= 0:
		get_node("MeshNode/Patterns/crate_pattern_%s" % pattern_num).visible = true
