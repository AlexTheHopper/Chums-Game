extends Node
class_name room

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var enemies_to_spawn: int

@export var spawn_timer: Timer

func _ready() -> void:
	for group in ["Chums_Enemy", "Chums_Neutral"]:
	#Remove all previous enemy chums:
		for chum in get_tree().get_nodes_in_group(group):
			chum.queue_free()
		
	#Fill new room:
	if Global.world_map[Global.room_location]["entered"]:
		load_room()
		
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
																	"state": chum.get_node("State_Machine").current_state.state_name,
																	"health": chum.get_node("Health").get_health()})
																
																
func load_room():
	for chum in Global.world_map[Global.room_location]["chums"]:
		var chum_to_add = ChumsManager.get_specific_chum(chum["type"])
		var chum_instance = chum_to_add.instantiate()
		
		chum_instance.global_position = chum["position"]
		chum_instance.get_node("Health").set_health(chum["health"])
		chum_instance.get_node("State_Machine").initial_state_override = chum["state"]
		
		get_parent().get_parent().get_node("Chums").add_child(chum_instance)
		
	
func place_friend_chums():
	#TODO
	print('Still have to place friend chums.')

func set_player_loc_on_entry():
	if len(Global.room_history) >= 2:
		var current_room = Global.room_history[-1]
		var prev_room = Global.room_history[-2]
		#Factor is how far from the centre of the room the player spawns.
		var factor = (Global.room_size / 2) - 5

		#Put player next to the door they just came out of
		player.global_position = Vector3(factor * (prev_room.x - current_room.x) + 1,
								 player.global_position.y, 
								factor * (prev_room.y - current_room.y) + 1)
		
		#Set the player camera rotation so it doesnt spin around when entering room
		var cam_rotation = fmod(player.get_node("Camera_Controller").rotation.y, 2 * PI)
		player.get_node("Camera_Controller").global_position = player.global_position
		player.get_node("Camera_Controller").rotation.y = cam_rotation
		#Set camera goal to nearest multiple of PI / 4
		player.camera_goal_horz = round(cam_rotation / (PI / 4)) * (PI / 4) # cam_rotation
