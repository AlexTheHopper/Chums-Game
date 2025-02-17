extends Node3D
class_name Quality_Popup

@onready var camera := get_viewport().get_camera_3d()
@onready var chum := get_parent()

@export var disp_name: Label
@export var disp_move_speed_title: Label
@export var disp_move_speed_value: Label
@export var disp_damage_title: Label
@export var disp_damage_value: Label
@export var disp_attack_speed_title: Label
@export var disp_attack_speed_value: Label

func _ready() -> void:
	#Set all values:
	disp_name.text = ChumsManager.chum_id_to_name[chum.chum_name]
	disp_move_speed_value.text = str(chum.quality["move_speed"])
	disp_damage_value.text = str(chum.quality["damage"])
	disp_attack_speed_value.text = str(chum.quality["speed"])
	
	$AnimationPlayer.play("fade_in")
	


func _process(delta: float) -> void:
	look_at(camera.global_position)
	
	
	
func remove():
	$AnimationPlayer.play("fade_out")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_out":
		queue_free()
