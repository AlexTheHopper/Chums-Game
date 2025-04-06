extends CanvasLayer

@onready var health_bar = $InGameHUD/HealthPanel/PlayerHealthBar
@onready var chum_count = $InGameHUD/ChumCountPanel/Value
@onready var IG_anim_player = $InGameHUD/AnimationPlayer
@onready var P_anim_player = $PauseMenu/AnimationPlayer
@export var is_paused: bool = false

func initialize() -> void:
	PlayerStats.hud_health_change.connect(change_health)
	change_health()
	PlayerStats.hud_max_health_change.connect(change_max_health)
	change_max_health()
	PlayerStats.hud_bracelets_change.connect(change_bracelets)
	change_bracelets()
	
	PlayerStats.player_chums_changed.connect(change_chum_count)
	chum_count.text = "0 / " + str(PlayerStats.player_max_chums)
	
	PlayerStats.insufficient_bracelets.connect(indicate_bracelets)
	PlayerStats.too_many_chums.connect(indicate_chum_count)
	
	P_anim_player.play("RESET")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		toggle_pause()
		
func toggle_pause():
	if is_paused and get_tree().paused:
		get_tree().paused = false
		P_anim_player.play_backwards("pause")
		
	elif not is_paused and not get_tree().paused:
		get_tree().paused = true
		P_anim_player.play("pause")
		
func change_health():
	health_bar.set_health(PlayerStats.player_health)
	
func change_max_health():
	health_bar.set_max_health(PlayerStats.player_max_health)
	
func change_chum_count():
	chum_count.text = str(len(get_tree().get_nodes_in_group("Chums_Friend"))) + " / " + str(PlayerStats.player_max_chums)

func change_bracelets():
	$InGameHUD/BraceletsPanel/Value.text = str(PlayerStats.bracelets)
	
func indicate_bracelets():
	IG_anim_player.play("insufficient_bracelets")
func indicate_chum_count():
	IG_anim_player.play("too_many_chums")
