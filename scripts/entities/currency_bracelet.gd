extends RigidBody3D

@onready var player := get_tree().get_first_node_in_group("Player")
@export var extra_vel: Vector3
var grace := 0.75

func _ready() -> void:
	apply_impulse(Vector3(randf_range(-1, 1), 7.5, randf_range(-1, 1)) + extra_vel)

func _physics_process(_delta: float) -> void:
	if grace <= 0.0:
		apply_impulse(Functions.vector_to_normalized(self, player))
		$CollectionZone/CollisionShape3D.disabled = false
	
func _process(delta: float) -> void:
	if grace > 0.0:
		grace = max(grace - delta, 0)


func _on_collection_zone_body_entered(body: Node3D) -> void:
	if body is Player:
		PlayerStats.bracelets_added(1)
		AudioManager.create_3d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_BRACELET_COLLECT)
		queue_free()
