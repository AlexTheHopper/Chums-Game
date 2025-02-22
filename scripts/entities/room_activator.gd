extends Node3D

var activated = false
var player_proximity = false
var spawning_finished = false

@onready var player := get_tree().get_first_node_in_group("Player")

signal activate_lever

func activate_chums():
	for chum in get_tree().get_nodes_in_group("Chums_Neutral"):
		chum.wake_up()
		
	for chum in get_tree().get_nodes_in_group("Chums_Friend"):
		chum.find_enemy()
		
	activate_lever.emit()
		
func finish_spawning():
	spawning_finished = true
	if player_proximity and not activated:
		$LetterIndicator.appear()

func _ready() -> void:
	rotation.y = Global.world_map[Global.room_location]["bell_angle"]
	if Global.world_map[Global.room_location]["activated"]:
		$Body/BellPivot.queue_free()
		activated = true
	elif Global.world_map[Global.room_location]["to_spawn"] == 0:
		finish_spawning()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interract") and player_proximity and not player.is_carrying and not activated and spawning_finished:
		activated = true
		activate_chums()
		$LetterIndicator.disappear()
		$AnimationPlayer.play("ring")
		
		Global.world_map[Global.room_location]["activated"] = true
		Global.in_battle = true


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		player_proximity = true
		if not activated and spawning_finished:
			$LetterIndicator.appear()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		player_proximity = false
		if not activated and spawning_finished:
			$LetterIndicator.disappear()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "ring":
		$AnimationPlayer.play("remove_bell")
	elif anim_name == "remove_bell":
		$Body/BellPivot.queue_free()
