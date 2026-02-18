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
			crate_whole.visible = false
			spawn_chum()
		else:
			#Crate has not been opened - no chum
			crate_broken.visible = false
	else:
		#Chum has been collected - no chum
		crate_whole.visible = false

func spawn_chum() -> void:
	var crate_chum = ChumsManager.get_specific_chum_id(Global.crate_info[crate_id]["chum_id"]).instantiate()
	crate_chum.bracelet_cost = 1
	for q in crate_chum.quality.keys():
		crate_chum.quality[q] = 0
	crate_chum.stats_set = true
	crate_chum.initial_state_override = "Knock"
	crate_chum.start_health = 0
	
	Global.current_room_node.get_parent().get_parent().get_node("Chums").add_child(crate_chum)

	crate_chum.global_position = global_position
	crate_chum.befriended.connect(on_chum_befriended)

func on_chum_befriended() -> void:
	Global.crates_broken.erase(crate_id)
