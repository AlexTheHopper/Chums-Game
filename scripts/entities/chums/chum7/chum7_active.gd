extends State
class_name Chum7_Active
@onready var state_name := "Active"

@onready var chum: CharacterBody3D
@onready var object: PackedScene = load("res://scenes/entities/currency_bracelet.tscn")
var emitting := false
var has_touched_floor := false

var to_emit := 0

func Enter():
	chum.anim_player.animation_finished.connect(_on_animation_player_animation_finished)
	chum.anim_player.play("Idle")
	emitting = false
	has_touched_floor = false
	
	#Connect to chums to emit stuff on their deaths:
	if chum.current_group == "Chums_Friend":
		for chum_ in get_tree().get_nodes_in_group("Chums_Enemy"):
			chum_.health_depleted.connect(on_something_death)

func Physics_Update(delta: float):
	if chum.is_on_floor():
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
		var obj = object.instantiate()
		Global.current_room_node.get_node("Currencies").add_child(obj)
		obj.global_position = chum.sleep_zone.global_position
		obj.apply_impulse(Vector3(0, 3, 0))
	to_emit = 0

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Attack":
		if to_emit > 0:
			chum.anim_player.play("Attack")
		else:
			emitting = false
			chum.anim_player.play("Idle")

func Exit():
	chum.anim_player.animation_finished.disconnect(_on_animation_player_animation_finished)
	emit_object()
	for cur_conn in self.get_incoming_connections():
		cur_conn.signal.disconnect(cur_conn.callable)
