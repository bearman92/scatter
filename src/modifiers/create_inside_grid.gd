@tool
extends "base_modifier.gd"


@export var spacing := Vector3(2.0, 2.0, 2.0)

var _min_spacing := 0.05


func _init() -> void:
	display_name = "Create Inside (Grid)"
	category = "Create"
	warning_ignore_no_transforms = true
	warning_ignore_no_shape = false
	can_restrict_height = true
	can_use_global_and_local_space = false # TODO: find a way to align the grid with the domain transform

	documentation.add_paragraph(
		"Place transforms along the edges of the ScatterShapes")

	var p = documentation.add_parameter("Spacing")
	p.set_type("vector3")
	p.set_description(
		"Defines the grid size along the 3 axes. A spacing of 1 means 1 unit
		of space between each transform on this axis.")
	p.set_cost(3)
	p.add_warning(
		"The smaller the value, the denser the resulting transforms list.
		Use with care as the performance impact will go up quickly.", 1)
	p.add_warning(
		"A value of 0 would result in infinite transforms, so it's capped to 0.05
		at least.")


func _process_transforms(transforms, domain, seed) -> void:
	spacing.x = max(_min_spacing, spacing.x)
	spacing.y = max(_min_spacing, spacing.y)
	spacing.z = max(_min_spacing, spacing.z)

	var center = domain.bounds.center
	var size = domain.bounds.size
	var half_size = size * 0.5
	var baseline: float = 0.0

	var width := int(ceil(size.x / spacing.x))
	var height := int(ceil(size.y / spacing.y))
	var length := int(ceil(size.z / spacing.z))

	if restrict_height:
		height = 1
		baseline = domain.bounds.max.y
	else:
		height = max(1, height) # Make sure height never gets below 1 or else nothing happens

	var max_count: int = width * length * height
	var new_transforms: Array[Transform3D] = []
	new_transforms.resize(max_count)

	var t: Transform3D
	var t_index := 0
	for i in width * length:
		for j in height:
			var pos = Vector3.ZERO
			pos.x = (i % width) * spacing.x
			pos.y = (j * spacing.y) + baseline
			pos.z = (i / width) * spacing.z
			pos += (center - half_size)

			if domain.is_point_inside(pos):
				t = Transform3D()
				t.origin = pos
				new_transforms[t_index] = t
				t_index += 1

	if t_index != new_transforms.size():
		new_transforms.resize(t_index)

	transforms.append(new_transforms)
	transforms.shuffle(seed)
