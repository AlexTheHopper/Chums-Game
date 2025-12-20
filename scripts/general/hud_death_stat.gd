extends Control

@export var stat_name: String
@export var stat_value: String
var panel

func _ready() -> void:
	panel = $Panel.get_theme_stylebox("panel").duplicate()
	$Panel.add_theme_stylebox_override("panel", panel)

	$Panel/Name.text = stat_name
	$Panel/Stat.text = stat_value
	$Panel/AnimationPlayer.play("enter")
