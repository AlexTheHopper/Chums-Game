extends Node
class_name room

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var enemies_to_spawn: int

var bracelet_tscn: PackedScene = preload("res://scenes/entities/currency_bracelet.tscn")

@export var spawn_timer: Timer

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
	place_friend_chums()

func save_room():
	#Remove previous data from room:
	Global.world_map[Global.room_location]["chums"] = []
	
	#Add current data:
	Global.world_map[Global.room_location]["entered"] = true
	Global.world_map[Global.room_location]["to_spawn"] = enemies_to_spawn
	
	for group in ["Chums_Enemy", "Chums_Neutral"]:
		for chum in get_tree().get_nodes_in_group(group):
			Global.world_map[Global.room_location]["chums"].append({"type": chum.chum_name,
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
		
func spawn_currency(type, location):
	var bracelet_instance = bracelet_tscn.instantiate()
	$Currencies.add_child(bracelet_instance)
	bracelet_instance.global_position = location
	
func place_friend_chums():
	#TODO
	print('Still have to place friend chums.')
	
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
		
		#Place friendly chums in front of the player:
		for chum in get_tree().get_nodes_in_group("Chums_Friend"):
			if chum.state_machine.current_state.name != "Carry":
				chum.global_position = lerp(player_pos, Vector3(1, 0, 1), 0.5) + Vector3(randf_range(-3, 3), 0, randf_range(-3, 3))
				chum.rotation.y = randf_range(0, 2*PI)
				chum.set_state("Idle")
