extends Node

const STREAM_COUNT: int = 8

var _available: Array[AudioStreamPlayer] = []
var _music_stream_player: AudioStreamPlayer
var _queue: Array[AudioStream] = []


func play(stream: AudioStream) -> void:
	_queue.append(stream)


func play_music(stream: AudioStream) -> void:
	_music_stream_player.stream = stream
	_music_stream_player.play()


func _ready() -> void:
	_music_stream_player = AudioStreamPlayer.new()
	_music_stream_player.finished.connect(_on_music_finished)
	_music_stream_player.bus = "Music"
	add_child(_music_stream_player)
	
	for i in STREAM_COUNT - 1:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_available.append(p)
		p.finished.connect(_on_stream_finished.bind(p))
		p.bus = "Sound"


func _process(_delta: float) -> void:
	while not _queue.is_empty() and not _available.is_empty():
		_available[0].stream = _queue.pop_front()
		_available[0].play()
		_available.pop_front()


func _on_music_finished() -> void:
	_music_stream_player.play()


func _on_stream_finished(player: AudioStreamPlayer) -> void:
	_available.append(player)
