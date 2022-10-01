extends Node2D

const WORLD_SIZE := 4
enum SectionType {
	CORRIDOR,
	DROP,
	EXIT,
	LANDING,
}

const ENTRANCE_SCENE := preload("res://sections/entrance.tscn")
const OUTSIDE_SCENE := preload("res://sections/outside.tscn")
const CORRIDORS: Array[Resource] = [
	preload("res://sections/corridors/corridor_1.tscn"),
	preload("res://sections/corridors/corridor_2.tscn"),
]
const DROPS: Array[Resource] = [
	preload("res://sections/drops/drop_1.tscn"),
	preload("res://sections/drops/drop_2.tscn"),
]
const LANDINGS: Array[Resource] = [
	preload("res://sections/landings/landing_1.tscn"),
	preload("res://sections/landings/landing_2.tscn"),
]

const WEAPONS: Array[Resource] = [
	preload("res://weapons/gun.tscn"),
	preload("res://weapons/machine_gun.tscn"),
	preload("res://weapons/shotgun.tscn"),
]

@onready var timer: Timer = $Timer
@onready var timer_label: Label = $CanvasLayer/TimerLabel
@onready var player: Player = $Player
@onready var world: Node2D = $World


func randomize_weapon() -> void:
	var weapon := WEAPONS[randi() % len(WEAPONS)]
	player.set_weapon(weapon)


func _generate_random_world() -> void:
	_clear_world()

	# Prepare a rough map to fill out with sections.
	var map := []
	for x in range(WORLD_SIZE):
		var column := []
		column.resize(WORLD_SIZE)
		map.append(column)

	# Walk downwards, determining map sections in the process.
	var current := Vector2i(randi() % WORLD_SIZE, 0)
	var start := current
	var end := start
	while end == start:
		var possible: Array[Vector2i] = []
		if current.x > 0 and map[current.x - 1][current.y] == null:
			possible.append(Vector2i.LEFT)
		if current.x < WORLD_SIZE - 1 and map[current.x + 1][current.y] == null:
			possible.append(Vector2i.RIGHT)
		if current.y < WORLD_SIZE and map[current.x][current.y + 1] == null:
			possible.append(Vector2i.DOWN)
		if possible.is_empty():
			end = current
		else:
			var next := current + possible[randi() % len(possible)]
			if next.y == current.y:
				map[next.x][next.y] = SectionType.CORRIDOR
			elif next.y == WORLD_SIZE - 1:
				end = current
			else:
				map[current.x][current.y] = SectionType.DROP
				map[next.x][next.y] = SectionType.LANDING
			current = next

	# Instantiate map sections.
	for x in range(0, WORLD_SIZE):
		for y in range(0, WORLD_SIZE):
			var section_scenes := []
			match map[x][y]:
				SectionType.CORRIDOR: section_scenes = CORRIDORS
				SectionType.DROP: section_scenes = DROPS
				SectionType.LANDING: section_scenes = LANDINGS
				_:  # Fill out the non-critical section with anything.
					section_scenes.append_array(CORRIDORS)
					section_scenes.append_array(DROPS)
					section_scenes.append_array(LANDINGS)
			if x == start.x and y == start.y:
				section_scenes = [ENTRANCE_SCENE]
			if section_scenes:
				var section: Section = section_scenes[randi() % len(section_scenes)].instantiate()
				section.position = Vector2(x * Section.WIDTH, y * Section.HEIGHT)
				world.add_child(section)

				if x == start.x and y == start.y:
					print_debug(section)
					var spawn: Marker2D = section.get_node("Spawn")
					player.global_position = spawn.global_position

	# Fill the outer edges to prevent entities from escaping the map.
	for i in range(WORLD_SIZE):
		_create_section(OUTSIDE_SCENE, Vector2i(i * Section.WIDTH, WORLD_SIZE * Section.HEIGHT))
		_create_section(OUTSIDE_SCENE, Vector2i(i * Section.WIDTH, -Section.HEIGHT))
		_create_section(OUTSIDE_SCENE, Vector2i(WORLD_SIZE * Section.WIDTH, i * Section.HEIGHT))
		_create_section(OUTSIDE_SCENE, Vector2i(-Section.WIDTH, i * Section.HEIGHT))


func _create_section(section_resource: Resource, section_position: Vector2i) -> void:
	var section: Section = section_resource.instantiate()
	section.global_position = section_position
	world.add_child(section)


func _clear_world() -> void:
	for section in world.get_children():
		section.queue_free()


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.html("#130208"))
	_generate_random_world()


func _process(_delta: float) -> void:
	timer_label.text = str(timer.time_left).pad_zeros(2).pad_decimals(2)


func _on_timer_timeout() -> void:
	randomize_weapon()
