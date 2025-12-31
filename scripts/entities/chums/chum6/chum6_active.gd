extends State
class_name Chum6_Active
@onready var state_name := "Active"

@onready var chum: CharacterBody3D
@onready var object: PackedScene = load("res://scenes/entities/heal_ball.tscn")
var emitting := false
var has_touched_floor := false

var to_emit := 0

func Enter():
	chum.anim_player.animation_finished.connect(_on_animation_player_animation_finished)
	chum.anim_player.play("Idle")
	emitting = false
	has_touched_floor = false
	
	#Connect to chums to emit stuff on their deaths:
	if chum.current_group == "Chums_Enemy":
		for chum_ in get_tree().get_nodes_in_group("Chums_Friend"):
			chum_.health_depleted.connect(on_something_death)
	else:
		for chum_ in get_tree().get_nodes_in_group("Chums_Enemy"):
			chum_.health_depleted.connect(on_something_death)

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
		for target_chum in get_tree().get_nodes_in_group(chum.current_group) + get_tree().get_nodes_in_group("Player"):
			if target_chum != chum and target_chum.has_damage() and not target_chum.is_temporary and not(target_chum is Player and chum.current_group == "Chums_Enemy"):
				var obj = object.instantiate()
				Global.current_room_node.get_node("Decorations").add_child(obj)
				obj.target = target_chum
				obj.global_position = chum.sleep_zone.global_position
				obj.heal_amount = chum.hitbox.damage
				obj.velocity = Vector3(0, 5.0, 0)
				if target_chum is not Player:
					target_chum.health_depleted.connect(obj.on_target_death)
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
	emit_object()
	chum.is_launched = false
	chum.hitbox.set_disabled(true)
	for cur_conn in self.get_incoming_connections():
		cur_conn.signal.disconnect(cur_conn.callable)
