extends Area3D

@export var origin: CharacterBody3D
@export var target: CharacterBody3D

@export var draws_agro_on_attack := false
var knockback_strength: float
var velocity := Vector3(0, 0, 0)
var active := false
var position_: Vector3
var target_position: Vector3
var move_speed := 2.5


func _ready() -> void:	
	if position_:
		global_position = position_
	$MeshInstance3D.rotation = Vector3(randf(), randf(), randf())

	if origin:
		draws_agro_on_attack = origin.draws_agro_on_attack
		$Hitbox.draws_agro_on_attack = draws_agro_on_attack
		$Hitbox.damage = origin.hitbox.damage
		knockback_strength = origin.knockback_strength
		var parent_group = Functions.get_parent_group(origin)
		if parent_group in ["Chums_Enemy"]:
			$Hitbox.set_as_enemy()
		elif parent_group in ["Chums_Friend", "Player"]:
			$Hitbox.set_as_friendly()

	if target:
		target_position = target.global_position + Vector3(0.0, 0.5, 0.0)
		set_vel_to_pos(global_position, target_position)

func _physics_process(delta: float) -> void:
	position += velocity * delta
	$MeshInstance3D.rotation.y += delta * 5

func set_vel_to_pos(start_pos, target_pos):
	#Velocity:
	var direction = (target_pos - start_pos).normalized() * move_speed
	velocity = direction * move_speed

func _on_body_entered(_body: Node3D) -> void:
	if active:
		call_deferred("disable_interaction")
		$CPUParticles3D.one_shot = true
		$CPUParticles3D.emitting = false

func disable_interaction():
	$Hitbox/CollisionShape3D.disabled = true
	$MeshInstance3D.visible = false

func get_agro_change_target():
	return origin

func _on_cpu_particles_3d_finished() -> void:
	queue_free()

func _on_grace_timeout() -> void:
	active = true
