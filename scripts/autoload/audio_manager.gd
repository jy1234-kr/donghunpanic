extends Node

var _players: Array[AudioStreamPlayer] = []


func _ready() -> void:
	for i in 4:
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		_players.append(player)


func play_tone(freq: float, duration: float = 0.15, volume: float = -12.0) -> void:
	var player := _get_free_player()
	if player == null:
		return
	var generator := AudioStreamGenerator.new()
	generator.mix_rate = 22050.0
	generator.buffer_length = duration
	player.stream = generator
	player.volume_db = volume
	player.play()
	_fill_tone(player, freq, duration)


func play_ui_click() -> void:
	play_tone(880.0, 0.05, -18.0)


func play_panic_pulse() -> void:
	play_tone(110.0, 0.2, -8.0)


func play_item_pickup() -> void:
	play_tone(660.0, 0.08, -14.0)
	await get_tree().create_timer(0.08).timeout
	play_tone(990.0, 0.1, -14.0)


func play_bell() -> void:
	for freq in [523.25, 659.25, 783.99]:
		play_tone(freq, 0.3, -10.0)
		await get_tree().create_timer(0.15).timeout


func play_ending_stinger(ending_id: String) -> void:
	match ending_id:
		"perfect", "improv":
			for freq in [392.0, 523.25, 659.25, 783.99]:
				play_tone(freq, 0.25, -8.0)
				await get_tree().create_timer(0.12).timeout
		"meltdown", "flee":
			for freq in [220.0, 185.0, 146.83]:
				play_tone(freq, 0.4, -6.0)
				await get_tree().create_timer(0.2).timeout
		_:
			play_tone(440.0, 0.3, -10.0)


func _get_free_player() -> AudioStreamPlayer:
	for player in _players:
		if not player.playing:
			return player
	return _players[0]


func _fill_tone(player: AudioStreamPlayer, freq: float, duration: float) -> void:
	await get_tree().process_frame
	var playback: AudioStreamGeneratorPlayback = player.get_stream_playback()
	if playback == null:
		return
	var mix_rate := 22050.0
	var sample_count := int(mix_rate * duration)
	for i in sample_count:
		var t := float(i) / mix_rate
		var envelope := 1.0 - (t / duration)
		var sample := sin(TAU * freq * t) * envelope * 0.25
		playback.push_frame(Vector2(sample, sample))
