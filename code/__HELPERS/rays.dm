/// Used to create rays on an item. Make sure to removefilter("rays") when done with it
/atom/proc/ray_helper(_priority = 1, _size = 40, _color = "#FFFFFF", _factor = 6, _density = 20)
	add_filter(name = "ray", priority = _priority, params = list(type = "rays", size = _size, color = _color , factor = _factor, density = _density))
