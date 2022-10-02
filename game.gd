extends Node2D

const HEALTH_PER_LIFE: int = 2
const MAX_LIVES: int = 3
var health: int = HEALTH_PER_LIFE
var lives: int = MAX_LIVES

@onready var camera: Camera2D = $Player/Camera
@onready var game_over_screen: GameOverScreen = $CanvasLayer/GameOverScreen
@onready var life_indicator_container: HBoxContainer = $Player/Control/HBoxContainer
@onready var timer: Timer = $Timer
@onready var timer_label: Label = $CanvasLayer/TimerLabel
@onready var player: Player = $Player
@onready var world: World = $World
var song_index := 0
var weapon_index := 0

const SONGS: Array[AudioStream] = [
	preload("res://music/song_1.ogg"),
	preload("res://music/song_2.ogg"),
]
const PORTAL_REACHED_SOUND := preload("res://world/portal_reached.wav")

const CROSSHAIR_SPRITE: Texture2D = preload("res://ui/crosshair.png")
const PLAYER_NORMAL_SPRITE := preload("res://player/player.png")
const PLAYER_HURT_SPRITE := preload("res://player/player_hurt.png")
const LIFE_INDICATOR_SPRITE := preload("res://ui/life_indicator.png")

const WEAPONS: Array[Resource] = [
	preload("res://weapons/gun.tscn"),
	preload("res://weapons/machine_gun.tscn"),
	preload("res://weapons/shotgun.tscn"),
]


func switch_weapon() -> void:
	weapon_index = (weapon_index + 1) % len(WEAPONS)
	var weapon := WEAPONS[weapon_index]
	player.set_weapon(weapon)


func randomize_world() -> void:
	var world_data := world.generate_random_world()
	var spawn: Vector2 = world_data[0]
	var portal = world_data[1]
	player.global_position = spawn
	portal.portal_reached.connect(_on_portal_reached)


func restart() -> void:
	timer.start()
	weapon_index = -1
	lives = MAX_LIVES
	health = HEALTH_PER_LIFE
	switch_weapon()
	randomize_world()
	update_life_indicators()
	Statistics.reset()


func update_life_indicators() -> void:
	var is_hurt := health != HEALTH_PER_LIFE
	player.get_node("Sprite").texture = PLAYER_HURT_SPRITE if is_hurt else PLAYER_NORMAL_SPRITE

	for indicator in life_indicator_container.get_children():
		indicator.queue_free()

	for _i in range(lives):
		var indicator := TextureRect.new()
		indicator.texture = LIFE_INDICATOR_SPRITE
		life_indicator_container.add_child(indicator)


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.html("#130208"))
	Input.set_custom_mouse_cursor(CROSSHAIR_SPRITE, Input.CURSOR_ARROW, CROSSHAIR_SPRITE.get_size() / 2)
	AudioPlayer.play_music(SONGS)
	game_over_screen.dismissed.connect(restart)
	game_over_screen.visible = false
	restart()


func _process(delta: float) -> void:
	timer_label.text = str(timer.time_left).pad_zeros(2).pad_decimals(2)
	camera.offset = ScreenShake.get_noise_offset(delta)


func _on_portal_reached(_player: Player) -> void:
	AudioPlayer.play(PORTAL_REACHED_SOUND)
	randomize_world.call_deferred()
	health = HEALTH_PER_LIFE
	update_life_indicators()
	Statistics.increment_levels_completed()


func _on_timer_timeout() -> void:
	switch_weapon()
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		if enemy.has_method("shoot_cascade"):
			enemy.call("shoot_cascade")


func _on_player_player_hurt() -> void:
	player.get_node("Sprite").texture = PLAYER_HURT_SPRITE
	health -= 1
	if health <= 0:
		lives -= 1
		health = HEALTH_PER_LIFE
		if lives <= 0:
			game_over_screen.enable()
		else:
			player.get_node("Sprite").texture = PLAYER_NORMAL_SPRITE
			randomize_world.call_deferred()
	update_life_indicators()
