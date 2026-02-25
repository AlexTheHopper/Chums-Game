extends Node3D

@onready var water: MeshInstance3D = $Mesh
@export var water_dim: Vector3 = Vector3(10.0, 1.0, 10.0)

var chum1 = false
var chum2 = false

var active := false
var chums := []
var chosen_quality: String

func _ready() -> void:
	water.mesh = water.mesh.duplicate()
	water.mesh.size = water_dim
	
	if not chosen_quality:
		#1: Atk Speed 2: Atk Damage 3: Move Spd 4: Health
		chosen_quality = ["attack_speed", "attack_damage", "move_speed", "health"][Global.world_map[Global.room_location]["room_specific_id"]]

func _on_timer_timeout() -> void:
	active = true


func _on_swap_zone_body_entered(body: Node3D) -> void:
	if not active:
		return
	if body is not Chum or not body.get("has_%s" % chosen_quality):
		throw_chum(body)
		return
	chums.append(body)

	if not chum1:
		chum1 = body
	elif not chum2:
		chum2 = body
	
	if chum1 and chum2:
		active = false
		await get_tree().create_timer(0.5).timeout
		swap_quality()


func _on_swap_zone_body_exited(body: Node3D) -> void:
	if body is not Chum or not active:
		return

	chum1 = false
	chum2 = false
	
	chums.erase(body)

func swap_quality() -> void:
	Global.print_dev("swapping chums %s and %s by %s" % [chum1.chum_id, chum2.chum_id, chosen_quality])
	var dummy = chum1.quality[chosen_quality]
	chum1.set_stat(chosen_quality, chum2.quality[chosen_quality])
	chum2.set_stat(chosen_quality, dummy)
	
	for chum in chums:
		throw_chum(chum)
	active = true

func throw_chum(chum) -> void:
	var angle: float = Functions.angle_to_xz(self, chum)
	var vel_2d: Vector2 = Vector2(sin(angle), cos(angle)) * 7.5
	
	chum.velocity = Vector3(vel_2d.x, 25.0, vel_2d.y)
	chum.is_launched = true
	chum.move_and_slide()
