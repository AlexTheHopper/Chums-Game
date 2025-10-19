class_name SoundMusic
extends Resource
## Yoinked from Aarimous - https://www.youtube.com/@Aarimous

## Stores the different types of sounds musics available to be played to distinguish them from another. Each new SoundMusic resource created should add to this enum, to allow them to be easily instantiated via [method AudioManager.create_3d_audio_at_location()] and [method AudioManager.create_audio()].
enum SOUND_MUSIC_TYPE {
	NULL,
	MENU,
	WORLD_1_IDLE,
	WORLD_1_BATTLE,
	WORLD_2_IDLE,
	WORLD_2_BATTLE,
	WORLD_3_IDLE,
	WORLD_3_BATTLE,
	WORLD_4_IDLE,
	WORLD_4_BATTLE,
}

@export_range(0, 10) var limit: int = 5 ## Maximum number of this SoundMusic to play simultaneously before culled.
@export var type: SOUND_MUSIC_TYPE ## The unique musics in the [enum SOUND_MUSIC_TYPE] to associate with this music. Each SoundMusic resource should have it's own unique [enum SOUND_MUSIC_TYPE] setting.
@export var sound_music: AudioStreamWAV ## The [AudioStreamWAV] audio resource to play.
@export_range(-40, 20) var volume: float = -20 ## The volume of the [member sound_music].
@export_range(0.0, 4.0,.01) var pitch_scale: float = 1.0 ## The pitch scale of the [member sound_music].
@export_range(0.0, 1.0,.01) var pitch_randomness: float = 0.0 ## The pitch randomness setting of the [member sound_music].
