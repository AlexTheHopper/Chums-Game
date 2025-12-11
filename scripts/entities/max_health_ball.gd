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
		velocity = lerp(velocity, 5 * Functions.vector_to_normalized(self, target), 0.05)
		
	move_and_slide()
	
func _process(delta: float) -> void:
	if grace > 0.0:
		grace = max(grace - delta, 0)

func _on_contact_zone_body_entered(body: Node3D) -> void:
	if body == target and active:
		if body is Chum:
			var to_increase = max(1, strength)
			body.increase_stats(0, 0, 0, to_increase, true)
		elif body is Player:
			body.health_node.max_health += int(strength * body.base_health / 10.0)
			
		remove()

func remove() -> void:
	active = false
	$CPUParticles3D.one_shot = true
	$CPUParticles3D.finished.connect(queue_free)

func on_target_death():
	remove()
