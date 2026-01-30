extends CanvasLayer

var to_display: Dictionary
var transitioning := false
const HUD_DEATH_STAT = preload("uid://ct186tsocgdcn")
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var death_stats: Control = $DeathStats
@onready var title_text: RichTextLabel = $DeathStats/Title/TitleText

signal return_to_main_menu

func _ready() -> void:
	if Global.current_room_node.TYPE == "endgame":
		title_text.text = tr("DEATHSTAT_REALITYSUCCEED")
	to_display = {
		tr("DEATHSTAT_TOTALCHUMS") + ": ": str(PlayerStats.player_chums_befriended),
		tr("DEATHSTAT_UNIQUECHUMS") + ": ": str(len(PlayerStats.player_unique_chums_befriended)),
		tr("DEATHSTAT_TOTALBRACELETS") + ": ": str(PlayerStats.player_bracelets_collected),
		tr("DEATHSTAT_SPENTBRACELETS") + ": ": str(PlayerStats.player_bracelets_spent),
	}
	animation_player.play("fade_in")
	
	var index = 0
	for stat in to_display.keys():
		create_stat(stat, to_display[stat], Vector2(326.0, 150.0 + index * 100.0))
		index += 1
		await get_tree().create_timer(0.5).timeout

func create_stat(stat_name: String, stat_value: String, pos: Vector2) -> void:
	var stat_to_add = HUD_DEATH_STAT.instantiate()
	stat_to_add.stat_name = stat_name
	stat_to_add.stat_value = stat_value
	stat_to_add.position = pos
	death_stats.add_child(stat_to_add)

func _process(_delta: float) -> void:
	if transitioning:
		return

	if Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("pause"):
		animation_player.play("fade_out")
		transitioning = true

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_out":
		if Global.current_room_node.TYPE == "endgame":
			#CREDITS HERE INSTEAD TODO
			return_to_main_menu.emit()
			queue_free()
		else:
			return_to_main_menu.emit()
			queue_free()
	transitioning = false
