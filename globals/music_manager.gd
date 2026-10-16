extends Node

var audio_player_1: AudioStreamPlayer
var audio_player_2: AudioStreamPlayer
var current_level_playing: int = 0

var music_tracks = {
	1: preload("res://assets/audio/music/level_1_bgm.mp3"),
	2: preload("res://assets/audio/music/level_2_bgm.mp3"),
	3: preload("res://assets/audio/music/level_3_bgm.mp3")
}

func _ready() -> void:
	audio_player_1 = AudioStreamPlayer.new()
	audio_player_1.bus = &'Music'
	add_child(audio_player_1)
	
	audio_player_2 = AudioStreamPlayer.new()
	audio_player_2.bus = &'Music'
	add_child(audio_player_2)
	
	for lvl in music_tracks:
		var stream = music_tracks[lvl]
		if stream is AudioStreamMP3:
			stream.loop = true
			
	Events.level_changed.connect(_on_level_changed)
	Events.game_state_changed.connect(_on_game_state_changed)

func _on_level_changed(lvl: int, _title: String) -> void:
	play_level(lvl)

func _on_game_state_changed(_old_s: int, new_s: int) -> void:
	if new_s == GameManager.GameState.PLAYING and current_level_playing == 0:
		play_level(1)
	elif new_s == GameManager.GameState.VICTORY or new_s == GameManager.GameState.DEFEAT:
		stop_music(1.5)

func play_level(lvl: int) -> void:
	var stream = music_tracks.get(lvl)
	if not stream or current_level_playing == lvl:
		return
	current_level_playing = lvl
	
	var active_p = audio_player_1 if not audio_player_1.playing else audio_player_2
	var inactive_p = audio_player_2 if active_p == audio_player_1 else audio_player_1
	
	active_p.stream = stream
	active_p.volume_db = -24.0
	active_p.play()
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(active_p, "volume_db", -3.0, 1.2)
	if inactive_p.playing:
		tween.tween_property(inactive_p, "volume_db", -40.0, 1.0)
		tween.chain().tween_callback(inactive_p.stop)

func stop_music(fade_time: float = 1.0) -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	if audio_player_1.playing:
		tween.tween_property(audio_player_1, "volume_db", -40.0, fade_time)
	if audio_player_2.playing:
		tween.tween_property(audio_player_2, "volume_db", -40.0, fade_time)
	current_level_playing = 0
