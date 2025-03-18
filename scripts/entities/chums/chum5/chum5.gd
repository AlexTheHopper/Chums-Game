extends Chum
class_name Chum5
var chum_str := "chum5"
var chum_name := "Slate"


var desc := "CHUM 5 DESC"

@onready var default_attack: Dictionary = {"speed": 1.6, #fastest quality still needs to be more than the attack animation length.
										"damage": 1,
										"distance": 10.0,
										"single_target": true}

var default_move_speed := 2.5

var max_health := 10.0
var start_health := 10.0

var maintains_agro := false
var changes_agro_on_damaged := true
var draws_agro_on_attack := true

var bracelet_count := 3
var bracelet_cost := 3

@onready var rock := $Body/Armature/Skeleton3D/BoneAttachment3D/RockZone/ProjRock
@onready var rock_zone := $Body/Armature/Skeleton3D/BoneAttachment3D/RockZone
@export var projectile: PackedScene

func set_rock_visibility(setting: bool):
	rock.visibility = setting
	
func throw_rock():
	var rock_inst = projectile.instantiate()
	rock_inst.target = target
	rock_inst.origin = self
	rock_inst.position_ = rock_zone.global_position
	Global.current_room_node.get_node("Decorations").add_child(rock_inst)
	
	
