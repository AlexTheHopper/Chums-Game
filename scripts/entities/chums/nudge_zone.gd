extends Area3D
@onready var parent: CharacterBody3D

func _ready() -> void:
	await owner.ready
	
	if owner is Player:
		parent = owner
	
	elif owner.owner is Chum:
		parent = owner.owner
	
	else:
		print("error with assigning nudge zone parent")

func _on_body_entered(body: Node3D) -> void:
	if parent is Player and body is not Chum:
		return
	elif body is not Chum or body == parent or parent.state_machine.current_state.state_name != "Active":
		return

	var angle: float = Functions.angle_to_xz(self, body)
	var vel_2d: Vector2 = Vector2(-sin(angle), -cos(angle)) * 2.5

	
	body.velocity = Vector3(vel_2d.x, 5.0, vel_2d.y)
	body.is_launched = true
	body.move_and_slide()
