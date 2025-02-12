extends Node3D

@export var health_node: Node
@export var current_health_bar: MeshInstance3D
@export var max_health_bar: MeshInstance3D
#@onready var material = $Health.mesh.material.duplicate()

func _ready() -> void:	
	#Connect to parent Health node to detect changed in health
	health_node.health_changed.connect(_on_health_changed)
	health_node.max_health_changed.connect(_on_max_health_changed)
	
	#Set initial values:
	_on_health_changed(0)
	_on_max_health_changed(0)
	
func _on_health_changed(difference):
	var health_ratio = max(health_node.health / health_node.max_health, 0.0)
	current_health_bar.scale.x = health_ratio
	current_health_bar.position.x = (1.0 - health_ratio) * 0.5 
	#Adjust colour:
	var health_color = Color(1.0 - health_ratio, health_ratio, 0.0)
	if health_ratio <= 0.0:
		health_color = Color(0.0, 0.0, 0.0)
	current_health_bar.mesh.material.albedo_color = health_color
	
func _on_max_health_changed(difference):
	pass
