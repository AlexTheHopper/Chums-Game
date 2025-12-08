extends CharacterBody3D

var target: CharacterBody3D
var grace := 1
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
	if body == target:
		if body is Chum:
			var to_increase: Dictionary = get_stats_to_increase(strength)
			body.increase_stats(to_increase[0], to_increase[1], to_increase[2], to_increase[3])
		elif body is Player:
			body.increase_stats(2 + int(strength/5.0))
			
		queue_free()

func get_stats_to_increase(count: int) -> Dictionary:
	var to_return = {0: 0, 1: 0, 2: 0, 3: 0}
	for i in range(count):
		to_return[[0, 1, 2, 3].pick_random()] += 1
	
	return to_return

func on_target_death():
	queue_free()
