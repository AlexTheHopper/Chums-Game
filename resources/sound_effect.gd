class_name SoundEffect 
extends Resource
## Yoinked from Aarimous - https://www.youtube.com/@Aarimous

## Stores the different types of sounds effects available to be played to distinguish them from another. Each new SoundEffect resource created should add to this enum, to allow them to be easily instantiated via [method AudioManager.create_3d_audio_at_location()] and [method AudioManager.create_audio()].
enum SOUND_EFFECT_TYPE {
	ON_PLAYER_ATTACKS,
	ON_PLAYER_HURT,
	ON_PLAYER_JUMP,
	ON_PLAYER_LAND,
	ON_PLAYER_HEAL,
	ON_PLAYER_DEATH,

	ON_CHUM_HURT_FRIENDLY,
	ON_CHUM_HEAL_FRIENDLY,
	ON_CHUM_DEATH_FRIENDLY,
	ON_CHUM_HURT_NOT_FRIENDLY,
	ON_CHUM_HEAL_NOT_FRIENDLY,
	ON_CHUM_DEATH_NOT_FRIENDLY,

	ON_BELL_HIT,
	ON_BRACELET_COLLECT,
	ON_STATUE_SHAKE,
}

@export_range(0, 10) var limit: int = 5 ## Maximum number of this SoundEffect to play simultaneously before culled.
@export var type: SOUND_EFFECT_TYPE ## The unique sound effect in the [enum SOUND_EFFECT_TYPE] to associate with this effect. Each SoundEffect resource should have it's own unique [enum SOUND_EFFECT_TYPE] setting.
@export var sound_effect: AudioStreamOggVorbis ## The [AudioStreamWAV] audio resource to play.
@export_range(-40, 20) var volume: float = -20 ## The volume of the [member sound_effect].
@export_range(0.0, 4.0,.01) var pitch_scale: float = 1.0 ## The pitch scale of the [member sound_effect].
@export_range(0.0, 1.0,.01) var pitch_randomness: float = 0.0 ## The pitch randomness setting of the [member sound_effect].

var audio_count: int = 0 ## The instances of this [AudioStreamMP3] currently playing.


## Takes [param amount] to change the [member audio_count]. 
func change_audio_count(amount: int) -> void:
	audio_count = max(0, audio_count + amount)


## Checkes whether the audio limit is reached. Returns true if the [member audio_count] is less than the [member limit].
func has_open_limit() -> bool:
	return audio_count < limit


## Connected to the [member sound_effect]'s finished signal to decrement the [member audio_count].
func on_audio_finished() -> void:
	change_audio_count(-1)
