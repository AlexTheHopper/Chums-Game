extends Node
class_name room

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var enemies_to_spawn: int

var bracelet_tscn: PackedScene = preload("res://scenes/entities/currency_bracelet.tscn")

@export var spawn_timer: Timer
@export var grid_map: GridMap

func _ready() -> void:
	for group in ["Chums_Enemy", "Chums_Neutral"]:
	#Remove all previous enemy chums:
		for chum in get_tree().get_nodes_in_group(group):
			chum.queue_free()
		
	#Fill new room:
	if Global.world_map[Global.room_location]["entered"]:
		load_room()
	else:
		self.decorate()
		
	if enemies_to_spawn > 0:
		if spawn_timer:
			spawn_timer.start()
			
	fill_tunnels()
			
func fill_tunnels():
	#Fix walls etc.
	var door_dist := 9
	if not Global.world_map[Global.room_location]["has_x_pos"]:
		if get_node_or_null("Doors/x_pos"):
			get_node("Doors/x_pos").queue_free()
		for w in range(-3, 4):
			#Solid Blocks
			grid_map.set_cell_item(Vector3(door_dist, 0, w), 5, 22)
			grid_map.set_cell_item(Vector3(door_dist + 1, 0, w), 4, 0)
			#Ramps:
			grid_map.set_cell_item(Vector3(door_dist - 1, 0, w), 12, 22)

	if not Global.world_map[Global.room_location]["has_x_neg"]:
		if get_node_or_null("Doors/x_neg"):
			get_node("Doors/x_neg").queue_free()
		for w in range(-3, 4):
			#Solid Blocks
			grid_map.set_cell_item(Vector3(-door_dist, 0, w), 5, 16)
			grid_map.set_cell_item(Vector3(-(door_dist + 1), 0, w), 4, 0)
			#Ramps:
			grid_map.set_cell_item(Vector3(-(door_dist - 1), 0, w), 12, 16)

	if not Global.world_map[Global.room_location]["has_z_pos"]:
		if get_node_or_null("Doors/z_pos"):
			get_node("Doors/z_pos").queue_free()
		for w in range(-3, 4):
			#Solid Blocks
			grid_map.set_cell_item(Vector3(w, 0, door_dist), 5, 10)
			grid_map.set_cell_item(Vector3(w, 0, door_dist + 1), 4, 0)
			#Ramps:
			grid_map.set_cell_item(Vector3(w, 0, door_dist - 1), 12, 0)

	if not Global.world_map[Global.room_location]["has_z_neg"]:
		if get_node_or_null("Doors/z_neg"):
			get_node("Doors/z_neg").queue_free()
		for w in range(-3, 4):
			#Solid Blocks
			grid_map.set_cell_item(Vector3(w, 0, -door_dist), 5, 0)
			grid_map.set_cell_item(Vector3(w, 0, -(door_dist + 1)), 4, 10)
			#Ramps:
			grid_map.set_cell_item(Vector3(w, 0, -(door_dist - 1)), 12, 0)

func save_room():
	#Remove previous data from room:
	Global.world_map[Global.room_location]["chums"] = []
	
	#Add current data:
	Global.world_map[Global.room_location]["entered"] = true
	Global.world_map[Global.room_location]["to_spawn"] = enemies_to_spawn
	
	for group in ["Chums_Enemy", "Chums_Neutral"]:
		for chum in get_tree().get_nodes_in_group(group):
			Global.world_map[Global.room_location]["chums"].append({"type": chum.chum_str,
																	"group": group,
																	"position": chum.global_position,
																	"state": chum.state_machine.current_state.state_name,
																	"health": chum.health_node.get_health(),
																	"max_health": chum.health_node.get_max_health(),
																	"attack": chum.attack,
																	"move_speed": chum.move_speed,
																	"quality": chum.quality,})
																
																
func load_room():
	var room_info = Global.world_map[Global.room_location]
	#Chums:
	for chum in room_info["chums"]:
		var chum_to_add = ChumsManager.get_specific_chum(chum["type"])
		var chum_instance = chum_to_add.instantiate()
		
		chum_instance.attack = chum["attack"]
		chum_instance.move_speed = chum["move_speed"]
		chum_instance.quality = chum["quality"]
		chum_instance.stats_set = true
		
		chum_instance.start_health = chum["health"]
		chum_instance.max_health = chum["max_health"]
		chum_instance.initial_state_override = chum["state"]
		
		get_parent().get_parent().get_node("Chums").add_child(chum_instance)
		
		chum_instance.global_position = chum["position"]
		chum_instance.spawn_currency.connect(spawn_currency)
	
	#Decorations:
	for deco in room_info["decorations"]:
		var deco_inst = DecorationManager.decorations[deco["name"]].instantiate()
		$Decorations.add_child(deco_inst)
		deco_inst.global_position = deco["position"]
		deco_inst.rotation.y = deco["rotation"]
	#Light:
	var street_light = DecorationManager.decorations["streetlamp"].instantiate()
	$Decorations.add_child(street_light)
	street_light.global_position = room_info["light_position"]
		
func spawn_currency(_type, location):
	var bracelet_instance = bracelet_tscn.instantiate()
	$Currencies.add_child(bracelet_instance)
	bracelet_instance.global_position = location
	
func decorate():
	pass

func set_player_loc_on_entry():
	if len(Global.room_history) >= 2:
		var current_room = Global.room_history[-1]
		var prev_room = Global.room_history[-2]
		#Factor is how far from the centre of the room the player spawns.
		var factor = (Global.room_size / 2) - 6.5

		#Put player next to the door they just came out of
		var player_pos = Vector3(factor * (prev_room.x - current_room.x) + 1,
								 player.global_position.y, 
								factor * (prev_room.y - current_room.y) + 1)
		player.global_position = player_pos
		
		#Set the player camera rotation so it doesnt spin around when entering room
		var cam_rotation = fmod(player.get_node("Camera_Controller").rotation.y, 2 * PI)
		player.get_node("Camera_Controller").global_position = player.global_position
		player.get_node("Camera_Controller").rotation.y = cam_rotation
		#Set camera goal to nearest multiple of PI / 4
		player.camera_goal_horz = round(cam_rotation / (PI / 4)) * (PI / 4) # cam_rotation
		
