extends Node3D

@onready var crate_whole: MeshInstance3D = $crate_whole
@onready var crate_broken: MeshInstance3D = $crate_broken

@export var crate_id: int

func _ready() -> void:
	await owner.ready
	if crate_id in Global.crates_broken.keys():
		#Chum has not been collected
		if Global.crates_broken[crate_id]:
			#Crate has been opened - spawn chum
			crate_whole.queue_free()
			spawn_object()
		else:
			#Crate has not been opened - no chum
			crate_broken.queue_free()
	else:
		#Chum has been collected - no chum
		crate_whole.queue_free()

func spawn_object() -> void:
	if Global.crate_info[crate_id]["object_id"] in ChumsManager.chums_list.keys():
		var crate_chum = ChumsManager.get_specific_chum_id(Global.crate_info[crate_id]["object_id"]).instantiate()
		crate_chum.bracelet_cost = 1
		for q in crate_chum.quality.keys():
			crate_chum.quality[q] = -5
		crate_chum.stats_set = true
		crate_chum.initial_state_override = "Knock"
		crate_chum.start_health = 0
		
		Global.current_room_node.get_parent().get_parent().get_node("Chums").add_child(crate_chum)

		crate_chum.global_position = global_position
		crate_chum.befriended.connect(on_object_used)
	
	else:
		var crate_bracelet = load("res://scenes/entities/currency_bracelet.tscn").instantiate()
		crate_bracelet.targets_player = false
		crate_bracelet.jump_on_spawn = false
		crate_bracelet.value = 15
		add_child(crate_bracelet)
		crate_bracelet.global_position = global_position
		crate_bracelet.scale = Vector3(1.5, 1.5, 1.5)
		crate_bracelet.freeze = true
		crate_bracelet.collected.connect(on_object_used)

func on_object_used() -> void:
	Global.crates_broken.erase(crate_id)
