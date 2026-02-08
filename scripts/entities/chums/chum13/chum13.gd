extends Chum
class_name Chum13
var chum_id := 13

var min_attack_speed := 0.75

var base_attack_speed := 2.0
var base_attack_damage := 10
var base_move_speed := 0.5
var base_health := 100
#Control of qualities
var has_attack_speed := true
var has_attack_damage := true
var has_move_speed := true
var has_health := true

var attack_distance := 0.85
var knockback_strength := 0.0
var knockback_weight := 1.0

#Chance that it maintains agro on chasing chum being hit
var maintains_agro := 0.0
var changes_agro_on_damaged := true
var draws_agro_on_attack := true
var always_targets_player := false

var bracelet_count := 1
var bracelet_cost := 3

var max_jump_dist := 5.0

var rising := false
@onready var raycast: RayCast3D = $RayCast3D
func jump_to_target() -> void:
	if raycast.is_colliding() and raycast.get_collider() is GridMap:
		rising = true
	var hit_time: float = 2.0 * (base_move_speed ** 2 / self.move_speed)
	#Go 95% of the way to target, unless it is further than max_jump_dist
	var target_pos: Vector3 = global_position.lerp(self.target.global_position, 0.9)
	var dir: Vector3 = target_pos - self.global_position
	var dist: float = dir.length()
	if dist > max_jump_dist:
		target_pos = self.global_position + dir.normalized() * max_jump_dist
	
	#Velocity:
	var dx = target_pos.x - self.global_position.x
	var dy = target_pos.y - self.global_position.y
	var dz = target_pos.z - self.global_position.z
	self.velocity = Vector3(dx, dy + 0.4 * self.get_gravity_dir() * hit_time * hit_time * -1, dz) / hit_time
	self.move_and_slide()
