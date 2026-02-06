extends Node3D
var active := false
var being_tscn = load("res://scenes/general/random_level_being.tscn")
@onready var particles: PackedScene = load("res://particles/void_deletion.tscn")
@onready var void_mesh: MeshInstance3D = $Void

@export var void_dim: Vector3 = Vector3(10.0, 1.0, 10.0)

signal spawn_currency

signal prisoner_entered

func _ready() -> void:
	void_mesh.mesh = void_mesh.mesh.duplicate()
	void_mesh.mesh.size = void_dim

func _on_kill_zone_body_entered(body: Node3D) -> void:
	if body is Chum and active:
		var particle = particles.instantiate()
		add_child(particle)
		particle.global_position = body.global_position
		
		if body.chum_id in [17, 18, 19, 20]:
			#Stop it from bumping other prisoners around - this creates too many beings floating
			body.generalchumbehaviour.nudge_collision.set_deferred("disabled", true)
			body.set_collision_layer_value(4, false)
			prisoner_entered.emit(body.chum_id)
			create_being_particles(body.chum_id, 2.0)
			kill_chum(body, 2.0)
		else:
			kill_chum(body)

func kill_chum(body: Chum, delay: float = 0.0) -> void:
	await get_tree().create_timer(delay).timeout
	if is_instance_valid(body):
		body.health_node.health = 0
		#Spawn Bracelets
		for n in body.bracelet_cost:
			spawn_currency.emit("bracelet", global_position, Vector3(0.0, 5.0, 0.0))
		body.call_deferred("queue_free")

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
	new_being.global_position = global_position - Vector3(0.0, void_dim.y, 0.0)
	for child in new_being.get_children():
		if child is BeingParticles:
			child.restart_particles()

func _on_fly_zone_body_entered(body: Node3D) -> void:
	if body is Player:
		var angle: float = Functions.angle_to_xz(self, body)
		var vel_2d: Vector2 = Vector2(sin(angle), cos(angle)) * 7.5
		
		body.velocity = Vector3(vel_2d.x, 25.0, vel_2d.y)
		body.is_launched = true

func _on_timer_timeout() -> void:
	active = true
