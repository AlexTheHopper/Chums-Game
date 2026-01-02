extends Area3D

@export var origin: CharacterBody3D
@export var target: CharacterBody3D

@export var hit_particle: PackedScene
@export var draws_agro_on_attack := false
@export var show_target: bool

@onready var red_overlay := preload("res://materials/outline_red.tres")
@onready var blue_overlay := preload("res://materials/outline_blue.tres")
@onready var black_overlay := preload("res://materials/outline_black.tres")
@onready var hitbox: Hitbox = $ProjSpear/Hitbox

@onready var spear_target := $SpearTarget
var knockback_strength: float
var velocity := Vector3(0, 0, 0)
var rotation_: Vector3
var active := false
var gravity_ := gravity
var position_: Vector3
var target_position: Vector3
var parent_group: String

var hit_time := 0.75

func _ready() -> void:
	$AnimationPlayer.play("fade_in")
	hitbox.damage = 1
	
	rotation_ = Vector3(0, randf_range(0.5, 1.0) * 10, 0)
	
	if position_:
		global_position = position_

	if origin:
		draws_agro_on_attack = origin.draws_agro_on_attack
		hitbox.draws_agro_on_attack = draws_agro_on_attack
		hitbox.damage = origin.hitbox.damage
		knockback_strength = origin.knockback_strength
		parent_group = Functions.get_parent_group(origin)
		if parent_group in ["Chums_Enemy"]:
			hitbox.set_as_enemy()
			spear_target.set_material_overlay(red_overlay)
		elif parent_group in ["Chums_Friend", "Player"]:
			hitbox.set_as_friendly()
			spear_target.set_material_overlay(blue_overlay)
		else:
			spear_target.set_material_overlay(black_overlay)
	
	if target:
		hit_time *= randf_range(0.8, 1.2)
		target_position = target.global_position + target.velocity * 0.5
		set_vel_to_pos(global_position, target_position, Vector3(0.0, 0.5, 0.0))
		spear_target.global_position = target_position
	


func set_vel_to_pos(start_pos: Vector3, target_pos: Vector3, offset: Vector3):
	#Velocity:
	var dx = target_pos.x - start_pos.x + offset.x
	var dy = target_pos.y - start_pos.y + offset.y
	var dz = target_pos.z - start_pos.z + offset.z
	velocity = Vector3(dx, dy + 0.5 * gravity_ * hit_time * hit_time, dz) / hit_time

func _process(delta: float) -> void:
	velocity += Vector3(0, -gravity_, 0) * delta
	if velocity:
		$ProjSpear.look_at(global_position - velocity)
	
func _physics_process(delta: float) -> void:
	position += velocity * delta
	spear_target.global_position = target_position

func _on_body_entered(body: Node3D) -> void:
	if active and body not in get_tree().get_nodes_in_group(parent_group):
		call_deferred("disable_interaction")
		$AnimationPlayer.play("fade_out")
		make_particles()
		velocity = Vector3(0, 0, 0)
		gravity_ = 0
		active = false

func disable_interaction():
	hitbox.get_node("CollisionShape3D").disabled = true

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_in":
		active = true
		
	elif anim_name == "fade_out":
		$ProjSpear.visible = false

func make_particles():
	var particle_inst = hit_particle.instantiate()
	add_child(particle_inst)
	particle_inst.completed.connect(delete)
	
func delete():
	queue_free()
	
func get_agro_change_target():
	return origin
