extends Node3D
var active := false
@onready var particles: PackedScene = load("res://particles/void_deletion.tscn")

func _on_kill_zone_body_entered(body: Node3D) -> void:
	if body is not Player and active:
		body.health_node.health = 0
		var particle = particles.instantiate()
		add_child(particle)
		particle.global_position = body.global_position
		body.call_deferred("queue_free")


func _on_fly_zone_body_entered(body: Node3D) -> void:
	if body is Player:
		var angle: float = Functions.angle_to_xz(self, body)
		var vel_2d: Vector2 = Vector2(sin(angle), cos(angle)) * 7.5
		
		body.velocity = Vector3(vel_2d.x, 25.0, vel_2d.y)
		body.is_launched = true

func _on_timer_timeout() -> void:
	active = true
