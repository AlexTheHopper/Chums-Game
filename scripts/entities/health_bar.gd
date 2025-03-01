extends Node3D

@export var health_node: Node
@export var current_health_bar: MeshInstance3D
@export var max_health_bar: MeshInstance3D

@export var notch_scene: PackedScene
const NOTCH_INC: int = 5

func _ready() -> void:	
	#Connect to parent Health node to detect changed in health
	health_node.health_changed.connect(_on_health_changed)
	health_node.max_health_changed.connect(_on_max_health_changed)
	
	#Set initial values:
	_on_health_changed(0)
	_on_max_health_changed(0)
	
	set_notches()

func set_notches():
	#Add notches
	var max_health = health_node.max_health
	if max_health > NOTCH_INC:
		var notch_count = floor(health_node.max_health / NOTCH_INC) + 1
		
		var bar_length = $Health.mesh.size.x
		var start_x = -0.5 * bar_length
				
		for n in notch_count:
			var notch = notch_scene.instantiate()
			$Frame.add_child(notch)
			
			#Position notch correctly
			var extra_x: float = bar_length - ((n * NOTCH_INC) / health_node.max_health) * bar_length
			notch.position = Vector3(start_x + extra_x, 0, 0)
	
func _on_health_changed(_difference):
	var health_ratio = max(health_node.health / health_node.max_health, 0.0)
	current_health_bar.scale.x = health_ratio
	current_health_bar.position.x = (1.0 - health_ratio) * 0.5 
	#Adjust colour:
	var health_color = Color(1.0 - health_ratio, health_ratio, 0.0)
	if health_ratio <= 0.0:
		health_color = Color(0.0, 0.0, 0.0)
	current_health_bar.mesh.material.albedo_color = health_color
	
func _on_max_health_changed(_difference):
	#Reset notches:
	for notch in $Frame.get_children():
		notch.queue_free()
	set_notches()
