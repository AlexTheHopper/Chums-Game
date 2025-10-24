extends Control

@onready var texture_rect: TextureRect = $TextureRect
@export var chum: Chum
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var panel

var initialised: bool = false

func _ready() -> void:
	panel = $Panel.get_theme_stylebox("panel").duplicate()
	$Panel.add_theme_stylebox_override("panel", panel)
	if chum:
		texture_rect.texture = load("res://assets/entities/chum_icons/chum%s_128.png" % [chum.chum_id])
		panel.bg_color = chum.indicator_color
	else:
		panel.bg_color = Color.from_rgba8(27, 27, 27, 255)
	animation_player.play("create")

func remove_chum() -> void:
	panel.bg_color = Color.from_rgba8(27, 27, 27, 255)
	animation_player.play("remove_chum")
	chum = null

func add_chum(new_chum: Chum) -> void:
	chum = new_chum
	panel.bg_color = chum.indicator_color
	texture_rect.texture = load("res://assets/entities/chum_icons/chum%s_128.png" % [chum.chum_id])
	animation_player.play("add_chum")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "full" and chum:
		panel.bg_color = chum.indicator_color
		$Panel.size = Vector2(50.0, 50.0)
	$Panel.position = Vector2(0.0, 0.0)
