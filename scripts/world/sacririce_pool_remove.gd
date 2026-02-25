extends Node3D
var active := false
var being_tscn = load("res://scenes/general/random_level_being.tscn")
@onready var particles: PackedScene = load("res://particles/void_deletion.tscn")
@onready var mesh: MeshInstance3D = $Mesh

@export var mesh_dim: Vector3 = Vector3(10.0, 1.0, 10.0)

signal chum_enter
signal chum_leave
signal throw_body

func _ready() -> void:
	mesh.mesh = mesh.mesh.duplicate()
	mesh.mesh.size = mesh_dim

func _on_enter_zone_body_entered(body: Node3D) -> void:
	if not active:
		return
	if body is not Chum:
		throw_body.emit(body)
		return
	chum_enter.emit(body)

func _on_enter_zone_body_exited(body: Node3D) -> void:
	if body is not Chum:
		return
	chum_leave.emit(body)

func delete_chum(chum: Chum) -> void:
	var particle = particles.instantiate()
	add_child(particle)
	particle.global_position = chum.global_position
	
	chum.health_node.health = 0
	chum.call_deferred("queue_free")
	
	if chum.chum_id in [17, 18, 19, 20]:
		create_being_particles(chum.chum_id, 2.0)

func create_being_particles(chum_id: int, delay: float = 0.0) -> void:
	await get_tree().create_timer(delay).timeout
	var new_being = being_tscn.instantiate()
	
	new_being.radius = 2.0
	new_being.speed = 0.5
	new_being.height = 3.0
	new_being.possible_particles = [chum_id]
	
	if Global.current_room_node.TYPE != "endgame":
		new_being.rising = true
	else:
		new_being.base = global_position.lerp(get_tree().get_first_node_in_group("Player").global_position, 0.5) + Vector3(0.0, randf_range(0.0, 3.0), -2.5)
	
	Global.current_room_node.get_node("Decorations").add_child(new_being)
	new_being.global_position = global_position - Vector3(0.0, mesh_dim.y, 0.0)
	for child in new_being.get_children():
		if child is BeingParticles:
			child.restart_particles()

func _on_timer_timeout() -> void:
	active = true
