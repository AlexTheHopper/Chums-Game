extends Node3D

var activated = false
var player_proximity = false
var spawning_finished = false

@onready var white_overlay := preload("res://materials/outline_white.tres")
@onready var black_overlay := preload("res://materials/outline_black.tres")
@onready var bell_mesh

@onready var frame_mesh_scene : Node
@onready var frame_mesh_node := $Body
@onready var bell_mesh_scene : Node
@onready var bell_mesh_node := $Body/BellPivot/BellMesh

@onready var player := get_tree().get_first_node_in_group("Player")

signal activate_bell


func _ready() -> void:
	#Set visuals:
	var mesh_num = 1
	if Global.current_world_num == 0:
		mesh_num = Global.room_location[1]
	elif Global.current_world_num:
		mesh_num = Global.current_world_num
		
	frame_mesh_scene = load("res://assets/world/bell_frame_%s.tscn" % [mesh_num]).instantiate()
	bell_mesh_scene = load("res://assets/world/bell_%s.tscn" % [mesh_num]).instantiate()
	frame_mesh_node.add_child(frame_mesh_scene)
	bell_mesh_node.add_child(bell_mesh_scene)
	bell_mesh = bell_mesh_scene.get_node("Bell")
	
	#If room is already done, remove bell
	rotation.y = Global.world_map[Global.room_location]["bell_angle"]
	if Global.world_map[Global.room_location]["activated"]:
		$Body/BellPivot.queue_free()
		activated = true
	elif Global.world_map[Global.room_location]["to_spawn"] == 0:
		finish_spawning()

#Runs on activation, makes chums do their thing
func activate_chums():
	for chum in get_tree().get_nodes_in_group("Chums_Neutral"):
		chum.wake_up()
		
	for chum in get_tree().get_nodes_in_group("Chums_Friend"):
		chum.find_enemy()
		
	activate_bell.emit()

#Allows bell to be activated
func finish_spawning():
	spawning_finished = true
	if player_proximity and not activated:
		bell_mesh.set_material_overlay(white_overlay)


#Activate room when smacked if conditions met
func attempt_activate():
	if player_proximity and not player.is_carrying and not activated and spawning_finished:
		activated = true
		activate_chums()
		bell_mesh.set_material_overlay(black_overlay)
		$AnimationPlayer.play("ring")
			
		Global.world_map[Global.room_location]["activated"] = true
		Global.in_battle = true

#Keep track of player proximity and change outline colour
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		player_proximity = true
		if not activated and spawning_finished:
			bell_mesh.set_material_overlay(white_overlay)
func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		player_proximity = false
		if not activated and spawning_finished:
			bell_mesh.set_material_overlay(black_overlay)

#Shrinks bell then removes it
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "ring":
		$AnimationPlayer.play("remove_bell")
	elif anim_name == "remove_bell":
		$Body/BellPivot.queue_free()

#Activate when hit by player
func _on_area_3d_area_entered(area: Area3D) -> void:
	if area is Hitbox:
		attempt_activate()
