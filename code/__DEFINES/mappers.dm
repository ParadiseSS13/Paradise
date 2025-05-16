/// Create directional subtypes for a path to simplify mapping.
#define MAPPING_DIRECTIONAL_HELPERS(path, offset_y, offset_x) ##path/directional/north {\
	dir = NORTH; \
	pixel_y = offset_y; \
} \
##path/directional/south {\
	dir = SOUTH; \
	pixel_y = -offset_y; \
} \
##path/directional/east {\
	dir = EAST; \
	pixel_x = offset_x; \
} \
##path/directional/west {\
	dir = WEST; \
	pixel_x = -offset_x; \
}

// If we want to set custom offset to each cardinal direction
#define MAPPING_DIRECTIONAL_HELPERS_CUSTOM(path, offset_north, offset_south, offset_east, offset_west) ##path/directional/north {\
	dir = NORTH; \
	pixel_y = offset_north; \
} \
##path/directional/south {\
	dir = SOUTH; \
	pixel_y = offset_south; \
} \
##path/directional/east {\
	dir = EAST; \
	pixel_x = offset_east; \
} \
##path/directional/west {\
	dir = WEST; \
	pixel_x = offset_west; \
}

#define MAPPING_DIRECTIONAL_HELPERS_MULTITILE(path, offset) ##path/directional/north {\
	dir = NORTH; \
} \
##path/directional/south {\
	dir = SOUTH; \
	pixel_y = -offset; \
} \
##path/directional/east {\
	dir = EAST; \
} \
##path/directional/west {\
	dir = WEST; \
	pixel_x = -offset; \
}
