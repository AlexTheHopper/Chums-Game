extends Control

@onready var texture_rect: TextureRect = $TextureRect
var panel
@export var chum: Chum
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var initialised: bool = false

func _ready() -> void:
	panel = $Panel.get_theme_stylebox("panel").duplicate()
	$Panel.add_theme_stylebox_override("panel", panel)
	if chum:
		texture_rect.texture = load("res://assets/entities/chum_icons/chum%s_128.png" % [chum.chum_id])
		panel.bg_color = Color.from_rgba8(40, 40, 40, 255)
	else:
		panel.bg_color = Color.from_rgba8(27, 27, 27, 255)
	animation_player.play("create")

func remove_chum() -> void:
	panel.bg_color = Color.from_rgba8(27, 27, 27, 255)
	animation_player.play("remove_chum")
	chum = null

func add_chum(new_chum: Chum) -> void:
	panel.bg_color = Color.from_rgba8(40, 40, 40, 255)
	chum = new_chum
	texture_rect.texture = load("res://assets/entities/chum_icons/chum%s_128.png" % [chum.chum_id])
	animation_player.play("add_chum")
