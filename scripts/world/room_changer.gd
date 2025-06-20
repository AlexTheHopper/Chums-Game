extends Area3D
class_name room_changer

@export var x_dir := 0
@export var z_dir := 0
@export var active := false

@onready var player := get_tree().get_first_node_in_group("Player")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	active = false
	var x_pos = position.x
	var z_pos = position.z
	x_dir = 0
	z_dir = 0

	if abs(x_pos) > abs(z_pos):
		if x_pos > 0:
			x_dir = 1
		else:
			x_dir = -1
	else:
		if z_pos > 0:
			z_dir = 1
		else:
			z_dir = -1

	if not Global.world_map.has(Vector2i(Global.room_location.x + x_dir, Global.room_location.y + z_dir)): #No room in direction
		queue_free()

func _on_body_entered(body: Node3D) -> void:
	if active and body is Player:
		active = false
		Global.current_room_node.save_room()
		Global.transition_to_level(Global.room_location + Vector2i(x_dir, z_dir))


func _on_grace_timeout() -> void:
	active = true
