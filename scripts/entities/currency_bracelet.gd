extends RigidBody3D

@onready var player := get_tree().get_first_node_in_group("Player")
var impulse_time := 0.5


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	apply_impulse(Vector3(randf_range(-1, 1), 5, randf_range(-1, 1)))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if impulse_time <= 0.0:
		apply_impulse(Functions.vector_to_normalized(self, player))
		$CollectionZone/CollisionShape3D.disabled = false
	
func _process(delta: float) -> void:
	if impulse_time > 0.0:
		impulse_time = max(impulse_time - delta, 0)


func _on_collection_zone_body_entered(body: Node3D) -> void:
	if body is Player and impulse_time <= 0.0:
		PlayerStats.bracelets_added(1)
		queue_free()
