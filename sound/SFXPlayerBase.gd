extends Node

class_name SFXPlayerBase

enum TypeOfPlayer {
	AUDIO_STREAM_PLAYER_3D,
	AUDIO_STREAM_PLAYER_2D,
	AUDIO_STREAM_PLAYER
}
## Pick type depending on scene.
## AUDIO_STREAM_PLAYER for UI, AUDIO_STREAM_PLAYER_2D for 2D scenes.
@export var type_of_player: TypeOfPlayer = TypeOfPlayer.AUDIO_STREAM_PLAYER_3D
@export var bus_name: String = SoundConstants.SFX_BUS_NAME

## Volume of the player at initialization.
## To lover the volume of the player, set it to a negative value.
@export var volume_db: float = 0.0

## The factor for the attenuation effect at initialization. 
## Higher values make the sound audible over a larger distance.
@export var unit_size: float = 10.0

## The maximum distance at which the sound is audible at initialization.
@export var max_distance: float = 30.0

## Sets the absolute maximum of the sound level, in decibels at initialization.
@export var max_db: float = -2

## Maximum number of concurrent sounds that can be played by this player.
@export var max_concurrent: int = 3


var _player_pool: Array[Variant] = []
var _playback_indexes: Array[int] = []
var _pool_ready: bool = false


func _create_player() -> void:
	var audio_stream_player: Variant
	if type_of_player == TypeOfPlayer.AUDIO_STREAM_PLAYER_2D:
		audio_stream_player = AudioStreamPlayer2D.new()
#		audio_stream_player.attenuation_filter_cutoff_hz = 20500

	if type_of_player == TypeOfPlayer.AUDIO_STREAM_PLAYER_3D:
		audio_stream_player = AudioStreamPlayer3D.new()
		audio_stream_player.attenuation_filter_cutoff_hz = 20500
		audio_stream_player.max_db = max_db
		audio_stream_player.unit_size = unit_size
		# https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer3d.html#enum-audiostreamplayer3d-attenuationmodel
		audio_stream_player.attenuation_model = 1 # ATTENUATION_INVERSE_SQUARE_DISTANCE
	else:
		audio_stream_player = AudioStreamPlayer.new()
	audio_stream_player.autoplay = false
	audio_stream_player.bus = bus_name
	audio_stream_player.volume_db = volume_db
	call_deferred("_attach_player", audio_stream_player)
	_player_pool.append(audio_stream_player)


func _create_player_pool() -> void:
	if _pool_ready:
		return
	_pool_ready = true
	for i in range(max_concurrent):
		_create_player()


func _update_playback_indexes(in_index: int) -> void:
	_playback_indexes.append(in_index)
	if _playback_indexes.size() > max_concurrent:
		_playback_indexes.pop_front()




func _retrieve_free_player() -> Variant:
	## Returns a free audio stream player from the pool.
	## If all players are busy, returns the oldest one.
	## Updates playback indexes accordingly.

	for i in range(_player_pool.size()):
		if !_player_pool[i].playing:
			_update_playback_indexes(i)
			return _player_pool[i]

	var oldest_index: int = _playback_indexes[0]
	return _player_pool[oldest_index]


func _attach_player(in_player: Node) -> void:
	if type_of_player == TypeOfPlayer.AUDIO_STREAM_PLAYER_2D or type_of_player == TypeOfPlayer.AUDIO_STREAM_PLAYER_3D:
		self.get_parent().add_child(in_player)
		in_player.global_transform = self.get_parent().global_transform
	else:
		add_child(in_player)