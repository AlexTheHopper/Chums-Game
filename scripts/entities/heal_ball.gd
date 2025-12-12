extends CharacterBody3D

var target: CharacterBody3D
var grace := 1.0
var active := true
@export var heal_amount := 1

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
		body.health_node.health += heal_amount
		remove()

func get_stats_to_increase(count: int) -> Dictionary:
	var to_return = {0: 0, 1: 0, 2: 0, 3: 0}
	for i in range(count):
		to_return[[0, 1, 2, 3].pick_random()] += 1
	
	return to_return

func remove() -> void:
	active = false
	$CPUParticles3D.one_shot = true
	$CPUParticles3D.finished.connect(queue_free)

func on_target_death():
	remove()
