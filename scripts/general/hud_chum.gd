extends Control

@onready var texture_rect: TextureRect = $TextureRect
@export var chum: Chum
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var initialised: bool = false

func _ready() -> void:
	if chum:
		texture_rect.texture = load("res://assets/entities/chum_icons/chum%s_128.png" % [chum.chum_id])
	animation_player.play("create")

func remove_chum() -> void:
	animation_player.play("remove_chum")
	chum = null

func add_chum(new_chum: Chum) -> void:
	chum = new_chum
	texture_rect.texture = load("res://assets/entities/chum_icons/chum%s_128.png" % [chum.chum_id])
	animation_player.play("add_chum")
