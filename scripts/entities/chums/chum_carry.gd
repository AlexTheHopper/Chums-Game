extends State
class_name Chum_Carry
@onready var state_name := "Carry"

@onready var chum: CharacterBody3D
@onready var player := get_tree().get_first_node_in_group("Player")
@onready var target_sprite := $ThrowTarget

var throw_vel_i: Vector3
var throw_hor := 10.0
var throw_vert := 7.5
var steps := 50
var time_step := 0.025
var target_info = false

func Enter() -> void:
	if not chum.is_in_group("Chums_Friend"):
		chum.make_friendly(true)
	chum.anim_player.play("Idle")
	
	target_sprite.visible = true

func Physics_Update(_delta: float) -> void:
	chum.global_position = lerp(chum.global_position, player.global_position + Vector3(0, 1.5, 0), 0.8)
	chum.rotation.y = lerp_angle(chum.rotation.y, player.player_goal_horz, 0.5)
	throw_vel_i = (Vector3(0, throw_hor, 0) + Vector3(0, 0, throw_vert).rotated(Vector3.UP, player.get_node("Armature").rotation.y))
	if Input.is_action_just_pressed("interract"):
		chum.velocity = throw_vel_i
		player.call_deferred("set", "is_carrying", false)
		if len(get_tree().get_nodes_in_group("Chums_Enemy")) > 0:
			Transitioned.emit(self, "Active")
		else:
			Transitioned.emit(self, "Idle")
	
	#Display target for where chum will land:
	target_info = get_target_info(chum.global_position, throw_vel_i)
	if target_info:
		target_sprite.global_position = target_info["position"]
		#Rotate target to match terrain
		var xform = target_sprite.global_transform
		xform.basis.y = target_info["normal"]
		xform.basis.x = -xform.basis.z.cross(target_info["normal"])
		xform.basis = xform.basis.orthonormalized()
		target_sprite.global_transform = target_sprite.global_transform.interpolate_with(xform, 0.2).orthonormalized()

	chum.move_and_slide()
	
func get_target_info(pos, vel):
	pos += Vector3(0, 0.3, 0)
	#var space_state = get_tree().current_scene.get_world_3d().direct_space_state
	var space_state = get_tree().get_root().get_node("Game").get_world_3d().direct_space_state
	var next_pos = pos
	
	for n in steps:
		next_pos = pos + vel * time_step

		var query = PhysicsRayQueryParameters3D.create(pos, next_pos)
		var result = space_state.intersect_ray(query)
		
		if result:
			if result["collider"] != player and result["collider"] != chum:
				return result
		
		vel.y += (chum.jump_gravity if vel.y > 0 else chum.fall_gravity) * time_step
		pos = next_pos
		
	return false
	
func Exit() -> void:
	chum.set_new_target()
	target_sprite.visible = false
