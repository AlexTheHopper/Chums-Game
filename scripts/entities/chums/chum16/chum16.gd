extends Chum
class_name Chum16
var chum_id := 16
var chum_str := "chum16"
var chum_name := "Flowey"

var desc := "Sends it love when an enemy chum is defeated in the form of a flaming hot molten rock."

var min_attack_speed := 2.55

var base_attack_speed := 0.0
var base_attack_damage := 15
var base_move_speed := 0.0
var base_health := 50
#Control of qualities
var has_attack_speed := false
var has_attack_damage := true
var has_move_speed := false
var has_health := true

var attack_distance := 1.3
var knockback_strength := 0.0
var knockback_weight := 1.0

#Chance that it maintains agro on chasing chum being hit
var maintains_agro := 0.0
var changes_agro_on_damaged := true
var draws_agro_on_attack := true
var always_targets_player := false

var bracelet_count := 1
var bracelet_cost := 3



@onready var fire_particles : CPUParticles3D = $Body/Armature/Skeleton3D/BoneAttachment3D/FireParticles
