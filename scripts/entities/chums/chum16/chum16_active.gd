extends State
class_name Chum16_Active
@onready var state_name := "Active"

@onready var chum: CharacterBody3D
@onready var object: PackedScene = load("res://scenes/world/proj_rock.tscn")
var emitting := false
var has_touched_floor := false

var to_emit := 0

func Enter():
	chum.anim_player.animation_finished.connect(_on_animation_player_animation_finished)
	chum.anim_player.play("Idle")
	to_emit = 0
	emitting = false
	has_touched_floor = false
	
	#Connect to chums to emit stuff on their deaths:
	if chum.current_group == "Chums_Enemy":
		for chum_ in get_tree().get_nodes_in_group("Chums_Friend"):
			chum_.health_depleted.connect(on_something_death)
	else:
		for chum_ in get_tree().get_nodes_in_group("Chums_Enemy"):
			chum_.health_depleted.connect(on_something_death)
	
	chum.fire_particles.emitting = true

func Physics_Update(delta: float):
	if chum.is_on_floor():
		chum.is_launched = false
		if not has_touched_floor:
			has_touched_floor = true
			chum.velocity = Vector3(0, 0, 0)
	else:
		has_touched_floor = false
		chum.velocity.y += chum.get_gravity_dir() * delta
	
	chum.move_and_slide()
	
func on_something_death():
	to_emit += 1
	if not emitting:
		emitting = true
		chum.anim_player.play("Attack")

func emit_object():
	for n in to_emit:
		for target_chum in get_tree().get_nodes_in_group("Chums_Enemy" if chum.current_group == "Chums_Friend" else "Chums_Friend") + get_tree().get_nodes_in_group("Player"):
			if target_chum != chum and not(target_chum is Player and chum.current_group == "Chums_Friend"):
				var obj = object.instantiate()
				obj.target = target_chum
				obj.origin = chum
				obj.position_ = chum.sleep_zone.global_position
				obj.on_fire = true
				Global.current_room_node.get_node("Decorations").add_child(obj)
	to_emit = 0

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Attack":
		if to_emit > 0:
			chum.anim_player.play("Attack")
		else:
			emitting = false
			chum.anim_player.play("Idle")
		if chum.target != chum.next_target and is_instance_valid(chum.next_target):
			if chum.next_target is Player:
				chum.set_target_to(chum.next_target)
			elif chum.next_target.state_machine.current_state.state_name == "Active":
				chum.set_target_to(chum.next_target)


func Exit():
	chum.anim_player.animation_finished.disconnect(_on_animation_player_animation_finished)
	chum.is_launched = false
	for cur_conn in self.get_incoming_connections():
		cur_conn.signal.disconnect(cur_conn.callable)
	
	chum.fire_particles.emitting = false
