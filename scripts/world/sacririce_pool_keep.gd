extends Node3D
var active := false
@onready var mesh: MeshInstance3D = $Mesh

@export var mesh_dim: Vector3 = Vector3(10.0, 1.0, 10.0)

signal chum_enter
signal chum_leave
signal throw_body

func _ready() -> void:
	mesh.mesh = mesh.mesh.duplicate()
	mesh.mesh.size = mesh_dim

func _on_enter_zone_body_entered(body: Node3D) -> void:
	if not active:
		return
	if body is not Chum:
		throw_body.emit(body)
		return
	chum_enter.emit(body)

func _on_enter_zone_body_exited(body: Node3D) -> void:
	if body is not Chum:
		return
	chum_leave.emit(body)

func _on_timer_timeout() -> void:
	active = true
