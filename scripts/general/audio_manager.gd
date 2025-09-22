extends Node3D
## Yoinked from Aarimous - https://www.youtube.com/@Aarimous
## Altered to work in 3D.

var sound_effect_dict: Dictionary = {} ## Loads all registered SoundEffects on ready as a reference.
@export var sound_effects: Array[SoundEffect] ## Stores all possible SoundEffects that can be played.

var sound_music_dict: Dictionary = {}
@export var sound_musics: Array[SoundMusic]
var current_music_type: SoundMusic.SOUND_MUSIC_TYPE
var current_music_node: AudioStreamPlayer
var ZERO_VOLUME_DB := -50.0
var MUSIC_FADE_TIME := 2.0

@onready var music: Node3D = $Music
@onready var effects: Node3D = $Effects

func _ready() -> void:
	for sound_effect: SoundEffect in sound_effects:
		sound_effect_dict[sound_effect.type] = sound_effect
	
	for sound_music: SoundMusic in sound_musics:
		sound_music_dict[sound_music.type] = sound_music


## Creates a sound effect at a specific location if the limit has not been reached. Pass [param location] for the global position of the audio effect, and [param type] for the SoundEffect to be queued.
func create_3d_audio_at_location(location: Vector3, type: SoundEffect.SOUND_EFFECT_TYPE) -> void:
	if sound_effect_dict.has(type):
		var sound_effect: SoundEffect = sound_effect_dict[type]
		if sound_effect.has_open_limit():
			sound_effect.change_audio_count(1)
			var new_3D_audio: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
			effects.add_child(new_3D_audio)
			new_3D_audio.global_position = location
			new_3D_audio.stream = sound_effect.sound_effect
			new_3D_audio.volume_db = sound_effect.volume
			new_3D_audio.pitch_scale = sound_effect.pitch_scale
			new_3D_audio.pitch_scale += randf_range(-sound_effect.pitch_randomness, sound_effect.pitch_randomness )
			new_3D_audio.finished.connect(sound_effect.on_audio_finished)
			new_3D_audio.finished.connect(new_3D_audio.queue_free)
			new_3D_audio.play()
	else:
		push_error("Audio Manager failed to find setting for type ", type)


## Creates a sound effect if the limit has not been reached. Pass [param type] for the SoundEffect to be queued.
func create_audio(type: SoundEffect.SOUND_EFFECT_TYPE) -> void:
	if sound_effect_dict.has(type):
		var sound_effect: SoundEffect = sound_effect_dict[type]
		if sound_effect.has_open_limit():
			sound_effect.change_audio_count(1)
			var new_audio: AudioStreamPlayer = AudioStreamPlayer.new()
			effects.add_child(new_audio)
			new_audio.stream = sound_effect.sound_effect
			new_audio.volume_db = sound_effect.volume
			new_audio.pitch_scale = sound_effect.pitch_scale
			new_audio.pitch_scale += randf_range(-sound_effect.pitch_randomness, sound_effect.pitch_randomness )
			new_audio.finished.connect(sound_effect.on_audio_finished)
			new_audio.finished.connect(new_audio.queue_free)
			new_audio.play()
			
	else:
		push_error("Audio Manager failed to find setting for type ", type)


func create_music(type: SoundMusic.SOUND_MUSIC_TYPE) -> void:
	if sound_music_dict.has(type):
		var sound_music: SoundMusic = sound_music_dict[type]

		#Do not start music again if its the same one
		if type == current_music_type:
			return

		if current_music_node:
			var current_tween = get_tree().create_tween().tween_property(current_music_node, "volume_db", ZERO_VOLUME_DB, MUSIC_FADE_TIME) #tween out current
			current_tween.finished.connect(remove_other_audios)
			#on completion - queue free

		var new_audio: AudioStreamPlayer = AudioStreamPlayer.new()
		music.add_child(new_audio)
		new_audio.stream = sound_music.sound_music
		new_audio.volume_db = ZERO_VOLUME_DB
		new_audio.pitch_scale = sound_music.pitch_scale
		new_audio.pitch_scale += randf_range(-sound_music.pitch_randomness, sound_music.pitch_randomness)
		new_audio.finished.connect(new_audio.play)
		get_tree().create_tween().tween_property(new_audio, "volume_db", sound_music.volume, MUSIC_FADE_TIME)
		new_audio.play()

		current_music_type = type
		current_music_node = new_audio
	else:
		push_error("Audio Manager failed to find setting for type ", type)

func remove_other_audios() -> void:
	for song in music.get_children():
		if song != current_music_node:
			song.queue_free()
