extends Area3D

@export var origin: CharacterBody3D
@export var target: CharacterBody3D

@export var hit_particle: PackedScene
@export var draws_agro_on_attack := false
@export var show_target: bool

@onready var red_overlay := preload("res://materials/outline_red.tres")
@onready var blue_overlay := preload("res://materials/outline_blue.tres")
@onready var black_overlay := preload("res://materials/outline_black.tres")

@onready var rock_target := $RockTarget
var velocity := Vector3(0, 0, 0)
var rotation_: Vector3
var active := false
var gravity_ := gravity
var position_: Vector3
var target_position: Vector3

var hit_time := 1.0

func _ready() -> void:
	$AnimationPlayer.play("fade_in")
	$Hitbox.damage = 1.0
	
	rotation_ = Vector3(0, randf_range(0.5, 1.0) * 10, 0)
	
	if position_:
		global_position = position_

	if origin:
		draws_agro_on_attack = origin.draws_agro_on_attack
		$Hitbox.draws_agro_on_attack = draws_agro_on_attack
		$Hitbox.damage = origin.attack["damage"]
		var parent_group = Functions.get_parent_group(origin)
		if parent_group in ["Chums_Enemy"]:
			$Hitbox.set_as_enemy()
			rock_target.set_material_overlay(red_overlay)
		elif parent_group in ["Chums_Friend", "Player"]:
			$Hitbox.set_as_friendly()
			rock_target.set_material_overlay(blue_overlay)
		else:
			rock_target.set_material_overlay(black_overlay)

	if target:
		target_position = target.global_position
		set_vel_to_pos(global_position, target_position)
		rock_target.global_position = target_position


func set_vel_to_pos(start_pos, target_pos):
	#Velocity:
	var dx = target_pos.x - start_pos.x
	var dy = target_pos.y - start_pos.y
	var dz = target_pos.z - start_pos.z
	velocity = Vector3(dx, dy + 0.5 * gravity_ * hit_time * hit_time, dz) / hit_time

func _process(delta: float) -> void:
	velocity += Vector3(0, -gravity_, 0) * delta
	$ProjRock.rotation += rotation_ * delta
	
func _physics_process(delta: float) -> void:
	position += velocity * delta
	rock_target.global_position = target_position

func _on_body_entered(_body: Node3D) -> void:
	if active:
		call_deferred("disable_interaction")
		$AnimationPlayer.play("fade_out")
		make_particles()
		velocity = Vector3(0, 0, 0)
		gravity_ = 0
		active = false

func disable_interaction():
	$Hitbox/CollisionShape3D.disabled = true

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_in":
		active = true
		
	elif anim_name == "fade_out":
		$ProjRock.visible = false
		#$RockTarget.visible = false

func make_particles():
	var particle_inst = hit_particle.instantiate()
	add_child(particle_inst)
	particle_inst.completed.connect(delete)
	
func delete():
	queue_free()
	
func get_agro_change_target():
	return origin
