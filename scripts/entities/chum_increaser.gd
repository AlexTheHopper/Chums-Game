extends StaticBody3D

var active := true
@export var increase_count: int = 1
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var particles := load("res://particles/chum_increaser_use.tscn")

func _ready() -> void:
	#Remove if have entered this world, or world is starting world. TODO this doesnt work
	#If you go to a new world, get this, then go to another room and reload, room history doesnt update but itll save your total chums.
	var past_worlds_data := Global.room_history.slice(0, Global.room_history.size() - 1)
	var past_worlds := past_worlds_data.map(func(item): return item[0])
	if Global.current_world_num in past_worlds:
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
	queue_free()
