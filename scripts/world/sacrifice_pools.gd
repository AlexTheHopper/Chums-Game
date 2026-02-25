extends Node3D

@onready var keep: Node3D = $SacrificeKeep
@onready var remove: Node3D = $SacrificeRemove
@onready var particles: CPUParticles3D = $CPUParticles3D

var active = true
var keep_chum = false
var remove_chum = false

func _ready() -> void:
	keep.chum_enter.connect(on_keep_enter)
	keep.chum_leave.connect(on_keep_leave)
	keep.throw_body.connect(throw_chum)
	
	remove.chum_enter.connect(on_remove_enter)
	remove.chum_leave.connect(on_remove_leave)
	remove.throw_body.connect(throw_chum)

func on_keep_enter(chum: Chum) -> void:
	if keep_chum or not active:
		throw_chum(chum)
		return
	keep_chum = chum
	check_to_sacrifice(remove_chum, keep_chum)

func on_keep_leave(chum: Chum) -> void:
	if keep_chum:
		if keep_chum == chum:
			keep_chum = false

func on_remove_enter(chum: Chum) -> void:
	if remove_chum or not active:
		throw_chum(chum)
	remove_chum = chum
	check_to_sacrifice(remove_chum, keep_chum)

func on_remove_leave(chum: Chum) -> void:
	if remove_chum:
		if remove_chum == chum:
			remove_chum = false

func check_to_sacrifice(chum1, chum2) -> void:
	if not chum1 or not chum2:
		return
	active = false
	await get_tree().create_timer(0.25).timeout
	var points = chum1.quality["attack_speed"] + chum1.quality["attack_damage"] + chum1.quality["move_speed"] + chum1.quality["health"]
	if remove_chum:
		remove.delete_chum(remove_chum)
		on_remove_leave(remove_chum)
	start_particles(points)
	await get_tree().create_timer(1.75).timeout
	if keep_chum:
		add_quality(keep_chum, points)
		throw_chum(keep_chum)
		active = true
	

func add_quality(chum: Chum, weight: int) -> void:
	weight = max(weight, 1)
	var to_increase: Dictionary = get_stats_to_increase(chum, weight)
	chum.increase_stats(to_increase["attack_speed"], to_increase["attack_damage"], to_increase["move_speed"], to_increase["health"], true)

func get_stats_to_increase(chum, count: int) -> Dictionary:
	var to_return = {"health": 0, "move_speed": 0, "attack_damage": 0, "attack_speed": 0}
	var to_increase := []
	
	#If chum has nothing, return nothing.
	if not chum.has_attack_speed and not chum.has_attack_damage and not chum.has_move_speed and not chum.has_health:
		return to_return

	if chum.has_attack_speed:
		to_increase.append("attack_speed")
	if chum.has_attack_damage:
		to_increase.append("attack_damage")
	if chum.has_move_speed:
		to_increase.append("move_speed")
	if chum.has_health:
		to_increase.append("health")

	for i in range(count):
		to_return[to_increase.pick_random()] += 1
	
	return to_return

func start_particles(num: int = 3):
	num = max(num, 1)
	particles.amount = num
	particles.emitting = true
	
func throw_chum(chum) -> void:
	var angle: float = Functions.angle_to_xz(self, chum)
	var vel_2d: Vector2 = Vector2(sin(angle), cos(angle)) * 7.5
	
	chum.velocity = Vector3(vel_2d.x, 25.0, vel_2d.y)
	chum.is_launched = true
	chum.move_and_slide()
