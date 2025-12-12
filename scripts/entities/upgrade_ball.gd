extends CharacterBody3D

var target: CharacterBody3D
var grace := 1
var active := true
@export var strength := 1

func _physics_process(_delta: float) -> void:
	if grace <= 0.0:
		$ContactZone/CollisionShape3D.disabled = false
		$CollisionShape3D.disabled = false
		
	if target and not grace:
		velocity = lerp(velocity, 5 * Functions.vector_to_normalized(self, target, Vector3(0.0, 0.5, 0.0)), 0.05)
		
	move_and_slide()
	
func _process(delta: float) -> void:
	if grace > 0.0:
		grace = max(grace - delta, 0)

func _on_contact_zone_body_entered(body: Node3D) -> void:
	if body == target and active:
		if body is Chum:
			var to_increase: Dictionary = get_stats_to_increase(body, strength)
			body.increase_stats(to_increase["attack_speed"], to_increase["attack_damage"], to_increase["move_speed"], to_increase["health"], true)
		elif body is Player:
			body.increase_stats(2 + 2 * strength)
			
		remove()

func get_stats_to_increase(chum, count: int) -> Dictionary:
	var to_return = {"health": 0, "move_speed": 0, "attack_damage": 0, "attack_speed": 0}
	var to_increase := []

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

func remove() -> void:
	active = false
	$CPUParticles3D.one_shot = true
	$CPUParticles3D.finished.connect(queue_free)

func on_target_death():
	remove()
