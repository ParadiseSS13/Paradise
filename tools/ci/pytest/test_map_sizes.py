from pathlib import Path

from avulto import DMM
from conftest import Lint

MAX_X_SIZE = 255
MAX_Y_SIZE = 255
MAX_Z_SIZE = 1

def test_map_sizes(lint: Lint, dmm_files: list[Path]):

    map_count = 0

    for map_file in dmm_files:
        map_count += 1
        dmm = DMM.from_file(map_file)

        if (
            dmm.size.x > MAX_X_SIZE
            or dmm.size.y > MAX_Y_SIZE
            or dmm.size.z > MAX_Z_SIZE
        ):
            lint.error(f"This map is >{MAX_X_SIZE}x{MAX_Y_SIZE}x{MAX_Z_SIZE} (Found: {dmm.size.x}x{dmm.size.y}x{dmm.size.z})", map_file)
