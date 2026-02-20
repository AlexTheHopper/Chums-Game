extends CanvasLayer

@onready var health_bar: Control = $InGameHUD/HealthPanel/PlayerHealthBar
@onready var IG_anim_player: AnimationPlayer = $InGameHUD/AnimationPlayer
@onready var P_anim_player: AnimationPlayer = $PauseMenu/AnimationPlayer
@onready var S_anim_player: AnimationPlayer = $SavedIndicator/AnimationPlayer
@onready var chum_indicators: Control = $InGameHUD/ChumIndicators
@onready var minimap: Control = $InGameHUD/Minimap/MinimapPanel/Minimap
@export var is_paused: bool = false
@export var is_returning: bool = false
var is_exit_warning: bool = false
const chum_indicator_tscn = preload("res://scenes/general/hud_chum.tscn")

func _ready() -> void:
	Global.hud = self
	IG_anim_player.play("enter")
	get_tree().get_first_node_in_group("Player").health_node.health_depleted.connect(remove_hud)

func initialise() -> void:
	PlayerStats.hud_health_change.connect(change_health)
	change_health()
	PlayerStats.hud_max_health_change.connect(change_max_health)
	change_max_health()
	PlayerStats.hud_bracelets_change.connect(change_bracelets)
	change_bracelets()
	
	PlayerStats.player_chums_increased.connect(chum_indicators_add)
	PlayerStats.player_chums_decreased.connect(chum_indicators_remove)
	
	PlayerStats.player_max_chums_increase.connect(max_chums_increased)
	
	PlayerStats.insufficient_bracelets.connect(indicate_bracelets)
	PlayerStats.too_many_chums.connect(indicate_chum_count)
	
	SaverLoader.Saved.connect(indicate_saved)
	
	P_anim_player.play("RESET")

func _process(_delta: float) -> void:
	if is_returning:
		return

	if Input.is_action_just_pressed("pause") and Global.is_alive and Global.current_room_node.TYPE != "endgame":
		AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.ON_MENU_BUTTON)
		toggle_pause()
	
	if is_paused and Input.is_action_just_pressed("attack"):
		AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.ON_MENU_BUTTON)
		if Global.in_battle and is_exit_warning:
			toggle_pause()
			get_tree().get_first_node_in_group("Player")._on_health_health_depleted()
		elif Global.in_battle:
			$PauseMenu/ReturnPanel/Value.text = "SAVE_DELETE"
			is_exit_warning = true
		else:
			is_returning = true
			toggle_pause()
			Global.return_to_menu(false, false)
	
	#Minimap rotation
	minimap.rotation = get_tree().get_first_node_in_group("Player").camera_controller.rotation.y

func toggle_pause():
	is_exit_warning = false
	if is_paused and get_tree().paused:
		get_tree().paused = false
		P_anim_player.play_backwards("pause")

		set_pause_volume(1.0)

	elif not is_paused and not get_tree().paused:
		$PauseMenu/ReturnPanel/Value.text = "MENU_RETURN"
		get_tree().paused = true
		P_anim_player.play("pause")

		set_pause_volume(0.25)

func set_pause_volume(amplitude) -> void:
	var vol_tween := get_tree().create_tween()
	vol_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	vol_tween.tween_property(AudioManager.current_music_node,
											"volume_db",
											AudioManager.sound_music_dict[AudioManager.current_music_type].volume * (2 - amplitude),
											1.0)
	vol_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

func change_health():
	health_bar.set_health(PlayerStats.player_health)
	
func change_max_health():
	health_bar.set_max_health(PlayerStats.player_max_health)
	
func change_bracelets():
	$InGameHUD/BraceletsPanel/Value.text = str(PlayerStats.bracelets)

func remove_hud() -> void:
	IG_anim_player.play_backwards("enter")
	
func indicate_bracelets() -> void:
	if IG_anim_player.current_animation == "enter":
		return
	IG_anim_player.play("insufficient_bracelets")
func indicate_chum_count() -> void:
	if IG_anim_player.current_animation == "enter":
		return
	IG_anim_player.play("too_many_chums")
	for child in chum_indicators.get_children():
		child.animation_player.play("full")
func indicate_saved() -> void:
	#S_anim_player.play("display")
	pass

func add_chum_indicators() -> void:
	var current_chums = get_tree().get_nodes_in_group("Chums_Friend")
	var current_chums_count = len(current_chums)

	for n in PlayerStats.player_max_chums:
		var new_indicator = chum_indicator_tscn.instantiate()
		new_indicator.global_position = get_indicator_position(n)
		
		#If there is a chum in that slot, visualise it
		if n + 1 <= current_chums_count:
			new_indicator.chum = current_chums[n]
		chum_indicators.add_child(new_indicator)

func max_chums_increased(extra_n):
	var current_n = PlayerStats.player_max_chums
	for n in range(current_n, current_n + extra_n):
		var new_indicator = chum_indicator_tscn.instantiate()
		new_indicator.global_position = get_indicator_position(n)
		chum_indicators.add_child(new_indicator)
		new_indicator.animation_player.play("create_extra")

func get_indicator_position(n: int) -> Vector2:
	var screen_size: Vector2 = $InGameHUD.size
	var indicator_gap: float = 10.0 #Pixels between indicators
	var indicator_size: float = 50.0
	var total_size: float = indicator_gap + indicator_size
	var max_indicators_vert = floor(screen_size.y / (indicator_gap + indicator_size))

	var x: float = screen_size.x - (total_size * floor(n / max_indicators_vert)) - total_size
	var y: float = total_size * fmod(n, max_indicators_vert) + indicator_gap
	return Vector2(x, y)

func chum_indicators_add(chum) -> void:
	for indicator in chum_indicators.get_children():
		if indicator.chum == null:
			indicator.add_chum(chum)
			return

func chum_indicators_remove(chum) -> void:
	for indicator in chum_indicators.get_children():
		if indicator.chum == chum:
			indicator.remove_chum()
			return

func display_minimap(value: bool) -> void:
	$InGameHUD/Minimap/MinimapBack.visible = value
	$InGameHUD/Minimap/MinimapPanel.visible = value
	$InGameHUD/Minimap/MinimapFade.visible = value
	
	if value == true:
		minimap.update_minimap()
