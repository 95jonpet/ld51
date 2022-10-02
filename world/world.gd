class_name World
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


# Generate a random world and return the spawn position.
func generate_random_world() -> Vector2:
	_clear_world()
	var spawn := Vector2.ZERO

	# Prepare a rough map to fill out with sections.
	var map: Array[Array] = []
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
		if current.y == WORLD_SIZE - 1:
			# Allow an exit to be placed on the lowest room by attempting to create a lower room.
			possible.append(Vector2i.DOWN)
		if current.y < WORLD_SIZE - 1 and map[current.x][current.y + 1] == null:
			# Only allow drops unless it creates a shaft.
			if current.y < 1 or map[current.x][current.y] != SectionType.LANDING:
				possible.append(Vector2i.DOWN)

		# Determine room types and the next room to visit/create.
		# Stop world generation when there are no more valid rooms to create or
		# when the walker cannot walk further down.
		if possible.is_empty():
			end = current
		else:
			var next := current + possible[randi() % len(possible)]
			if next.y == current.y:  # Moving horizontally.
				map[next.x][next.y] = SectionType.CORRIDOR
			elif next.y == WORLD_SIZE:  # Moving below the bottom of the world.
				# Place an exit if attempting to create a room beneath the lowest room.
				# The current room does not need to be modified as nothing else changes.
				end = current
			else:  # Moving down.
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
				add_child(section)

				if x == start.x and y == start.y:
					print_debug(section)
					spawn = section.get_node("Spawn").global_position

	# Fill the outer edges to prevent entities from escaping the map.
	for i in range(WORLD_SIZE):
		_create_section(OUTSIDE_SCENE, Vector2i(i * Section.WIDTH, WORLD_SIZE * Section.HEIGHT))
		_create_section(OUTSIDE_SCENE, Vector2i(i * Section.WIDTH, -Section.HEIGHT))
		_create_section(OUTSIDE_SCENE, Vector2i(WORLD_SIZE * Section.WIDTH, i * Section.HEIGHT))
		_create_section(OUTSIDE_SCENE, Vector2i(-Section.WIDTH, i * Section.HEIGHT))

	return spawn


func _create_section(section_resource: Resource, section_position: Vector2i) -> void:
	var section: Section = section_resource.instantiate()
	section.global_position = section_position
	add_child(section)


func _clear_world() -> void:
	for section in get_children():
		section.queue_free()
