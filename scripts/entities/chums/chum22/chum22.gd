extends Chum
class_name Chum22
var chum_id := 22
var chum_str := "chum22"
var chum_name := "Ashi"

var desc := "Just a cute doggo."

var min_attack_speed := 3.2

var base_attack_speed := 4.5
var base_attack_damage := 50
var base_move_speed := 3.0
var base_health := 150
#Control of qualities
var has_attack_speed := true
var has_attack_damage := true
var has_move_speed := true
var has_health := true

var attack_distance := 3.0
var knockback_strength := 0.0
var knockback_weight := 5.0

#Chance that it maintains agro on chasing chum being hit
var maintains_agro := 0.0
var changes_agro_on_damaged := true
var draws_agro_on_attack := true
var always_targets_player := false

var bracelet_count := 1
var bracelet_cost := 3

func start_fire() -> void:
	$Body/Armature/Skeleton3D/BoneAttachment3D/CPUParticles3D.emitting = true
