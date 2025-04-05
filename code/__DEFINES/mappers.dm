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

#define BUTTON_HELPERS(path, offset_1, offset_2) \
##path/offset/northwest {\
	dir = NORTHWEST; \
	pixel_x = -offset_2; \
	pixel_y = offset_1; \
} \
##path/offset/north {\
	dir = NORTH; \
	pixel_x = offset_2; \
	pixel_y = offset_1; \
} \
##path/offset/northeast {\
	dir = NORTHEAST; \
	pixel_x = offset_1; \
	pixel_y = offset_2; \
} \
##path/offset/east {\
	dir = EAST; \
	pixel_x = offset_1; \
	pixel_y = -offset_2; \
} \
##path/offset/southeast {\
	dir = SOUTHEAST; \
	pixel_x = offset_2; \
	pixel_y = -offset_1; \
} \
##path/offset/south {\
	dir = SOUTH; \
	pixel_x = -offset_2; \
	pixel_y = -offset_1; \
} \
##path/offset/southwest {\
	dir = SOUTHWEST; \
	pixel_x = -offset_1; \
	pixel_y = -offset_2; \
} \
##path/offset/west {\
	dir = WEST; \
	pixel_x = -offset_1; \
	pixel_y = offset_2; \
}
