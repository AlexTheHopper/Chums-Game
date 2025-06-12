extends CharacterBody3D

var target: CharacterBody3D
var grace := 1
@export var heal_amount = 1

func _physics_process(_delta: float) -> void:
	if grace <= 0.0:
		$ContactZone/CollisionShape3D.disabled = false
		$CollisionShape3D.disabled = false
		
	if target:
		velocity = lerp(velocity, 5 * Functions.vector_to_normalized(self, target), 0.1)
		
	move_and_slide()
	
func _process(delta: float) -> void:
	if grace > 0.0:
		grace = max(grace - delta, 0)

func _on_contact_zone_body_entered(body: Node3D) -> void:
	if body == target:
		body.health_node.health += heal_amount
		queue_free()

func on_target_death():
	queue_free()
