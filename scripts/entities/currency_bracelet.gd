extends RigidBody3D
class_name CurrencyBracelet

@onready var player := get_tree().get_first_node_in_group("Player")
@export var extra_vel: Vector3
@export var value := 1
@export var targets_player := true
@export var jump_on_spawn := true
var active := false

func _ready() -> void:
	if jump_on_spawn:
		apply_impulse(Vector3(randf_range(-1, 1), 7.5, randf_range(-1, 1)) + extra_vel)

func _physics_process(_delta: float) -> void:
	if not active or not targets_player:
		return
	apply_impulse(Functions.vector_to_normalized(self, player))

func _on_collection_zone_body_entered(body: Node3D) -> void:
	if body is Player:
		PlayerStats.bracelets_added(value)
		AudioManager.create_3d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_BRACELET_COLLECT)
		queue_free()


func _on_grace_timer_timeout() -> void:
	active = true
	$CollectionZone/CollisionShape3D.disabled = false
