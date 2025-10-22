extends StaticBody3D

var active := true
@export var increase_count: int = 1
@export var lantern_world: int
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var particles := load("res://particles/chum_increaser_use.tscn")

func _ready() -> void:
	if PlayerStats.collected_lanterns[lantern_world]:
		queue_free()
	animation_player.play("idle")

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area is Hitbox and active:
		active = false
		animation_player.play("use")

func give_extra_max_chums(n) -> void:
	PlayerStats.add_max_chums(n)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "use":
		var particle_inst = particles.instantiate()
		add_child(particle_inst)
		particle_inst.completed.connect(delete)
		
func delete():
	give_extra_max_chums(increase_count)
	PlayerStats.collected_lanterns[lantern_world] = true
	queue_free()
