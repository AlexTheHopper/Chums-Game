extends Node3D

func _physics_process(delta: float) -> void:
	$Hearts.rotation.y += delta / 2

func _on_heal_zone_body_entered(body: Node3D) -> void:
	print("healing: " + str(body))
	body.health_node.health += 5.0


func _on_fly_zone_body_entered(body: Node3D) -> void:
	var pos = body.global_position - Vector3(1.0, 0, 1.0)
	var x = pos.x + (5.0 if pos.x > 0 else -5.0)
	var y = 25.0
	var z = pos.z + (5.0 if pos.z > 0 else -5.0)
	body.velocity = Vector3(x, y, z)
	body.is_launched = true
