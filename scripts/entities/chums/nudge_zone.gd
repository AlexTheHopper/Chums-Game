extends Area3D
@onready var parent: CharacterBody3D

func _ready() -> void:
	await owner.ready
	
	if owner is Player:
		parent = owner
	
	elif owner.owner is Chum:
		parent = owner.owner
	
	else:
		push_error("error with assigning nudge zone parent")

func _on_body_entered(body: Node3D) -> void:
	if parent is Player and body is not Chum:
		return
	elif body is not Chum or body == parent or parent.state_machine.current_state.state_name not in ["Active", "Sleep", "Idle"]:
		return

	var vel_2d = 2.5 * Vector2(body.velocity.x, body.velocity.z).normalized() + Vector2(randf() - 0.5, randf() - 0.5)

	
	body.velocity = Vector3(vel_2d.x, 7.5, vel_2d.y)
	body.is_launched = true
	body.move_and_slide()
