extends CharacterBody3D
var spin_speed := 0.0
var particles := load("res://particles/upgrade_use.tscn")
var particles_2 := load("res://particles/upgrade_use_2.tscn")

func _ready() -> void:
	spin_speed = randf_range(0.1, 0.5)

func _physics_process(delta: float) -> void:
	rotation.y += spin_speed * delta

func remove():
	$AnimationPlayer.play("remove")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "remove":
		var particle_inst = particles.instantiate()
		add_child(particle_inst)
		particle_inst.completed.connect(delete)
		
		#To try show the combination of stars:
		add_child(particles_2.instantiate())
		
func delete():
	queue_free()
