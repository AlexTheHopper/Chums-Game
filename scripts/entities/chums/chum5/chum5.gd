extends Chum
class_name Chum5
var chum_str := "chum5"
var chum_name := "Slate"


var desc := "An old log that has harnessed the modern technologies of the catapult, allowing it to conjure rocks from nowhere and hurl them some distance. It's a tough job though, since this chum has little health and those rocks can also conjure a bit of hatred when hitting one's head."

@onready var default_attack: Dictionary = {"speed": 1.6, #fastest quality still needs to be more than the attack animation length.
										"damage": 10,
										"distance": 10.0,
										"single_target": true}

var default_move_speed := 2.5
var can_walk := true

var max_health := 50
var start_health := 50

#Chance that it maintains agro on chasing chum being hit
var maintains_agro := 0.0
var changes_agro_on_damaged := true
var draws_agro_on_attack := true
var always_targets_player := false

var bracelet_count := 1 if not Global.dev_mode else 1
var bracelet_cost := 3 if not Global.dev_mode else 1

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
	
	
