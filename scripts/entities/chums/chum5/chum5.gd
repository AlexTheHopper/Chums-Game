extends Chum
class_name Chum5
var chum_id := 5
var chum_name := "Slate"

var desc := "An old log that has harnessed the modern technologies of the catapult, allowing it to conjure rocks from nowhere and hurl them some distance. It's a tough job though, since this chum has little health and those rocks can also conjure a bit of hatred when hitting one's head."

var min_attack_speed := 1.5

var base_attack_speed := 1.6
var base_attack_damage := 10
var base_move_speed := 2.5
var base_health := 50
#Control of qualities
var has_attack_speed := true
var has_attack_damage := true
var has_move_speed := true
var has_health := true

var attack_distance := 10.0
var knockback_strength := 0.0
var knockback_weight := 1.25

#Chance that it maintains agro on chasing chum being hit
var maintains_agro := 0.0
var changes_agro_on_damaged := true
var draws_agro_on_attack := true
var always_targets_player := false

var bracelet_count := 1
var bracelet_cost := 3

@onready var rock_zone := $Body/Armature/Skeleton3D/BoneAttachment3D/RockZone
@export var projectile: PackedScene

func throw_rock():
	var rock_inst = projectile.instantiate()
	rock_inst.target = target
	rock_inst.origin = self
	rock_inst.position_ = rock_zone.global_position
	Global.current_room_node.get_node("Decorations").add_child(rock_inst)
	
	
