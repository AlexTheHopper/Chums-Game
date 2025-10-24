extends Node3D

@export var hit_zone: Area3D
@export var mesh: MeshInstance3D
@export var gradient: Gradient
@export var sound_effect: SoundEffect.SOUND_EFFECT_TYPE

const DECORATION_DESTROYED = preload("res://particles/decoration_destroyed.tscn")
var can_be_removed := true

func _ready() -> void:
	hit_zone.area_entered.connect(_on_area_entered)

func _on_area_entered(area) -> void:
	if area is Hitbox and can_be_removed:
		can_be_removed = false
		var angle = Functions.angle_to_xz(area, self)
		var particles = DECORATION_DESTROYED.instantiate()
		if gradient:
			particles.gradient = gradient
		add_child(particles)
		particles.rotation.y = angle
		get_tree().create_tween().tween_property(mesh, "scale", Vector3(0.0, 0.0, 0.0), 0.1)
		particles.completed.connect(_on_particles_completed)
		
		AudioManager.create_3d_audio_at_location(self.global_position, sound_effect)

func _on_particles_completed() -> void:
	Global.world_map[Global.room_location]["removed_decorations"].append(global_position)
	queue_free()
