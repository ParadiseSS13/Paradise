use std::{collections::{HashMap, HashSet}, iter::Map};

use super::core::GridMap;

use dmmtools::dmm::{Coord2, Coord3, Prefab};
use eyre::ContextCompat;
use geometry::{distance, get_direction, Directions, Rect, DIRECTIONS};
use rand::{seq::SliceRandom, thread_rng, Rng};
use serde::{Deserialize, Serialize};

mod geometry;

#[derive(Clone, PartialEq, Eq, PartialOrd, Ord)]
struct MapTileVal(i8);

// positive values are reserved for indexes into the list of available room configurations
const MAP_TILE_IGNORE: MapTileVal = MapTileVal(-1);
const MAP_TILE_WALL: MapTileVal = MapTileVal(-2);
const MAP_TILE_FLOOR: MapTileVal = MapTileVal(-3);
const MAP_TILE_RESERVED_FLOOR: MapTileVal = MapTileVal(-4);

const MAPMANIP_MARKER_PREFIX: &str = "/obj/effect/map_effect/marker/mapmanip";
const SCALE: i32 = 3;
const MAX_ROOM_PLACEMENT_TRIES: i32 = 200;

const SAFE_VERTICAL_HALL: &[MapTileVal; 9] = &[
    MAP_TILE_WALL,
    MAP_TILE_FLOOR,
    MAP_TILE_WALL,
    MAP_TILE_WALL,
    MAP_TILE_FLOOR,
    MAP_TILE_WALL,
    MAP_TILE_WALL,
    MAP_TILE_FLOOR,
    MAP_TILE_WALL,
];

const SAFE_HORIZONTAL_HALL: &[MapTileVal; 9] = &[
    MAP_TILE_WALL,
    MAP_TILE_WALL,
    MAP_TILE_WALL,
    MAP_TILE_FLOOR,
    MAP_TILE_FLOOR,
    MAP_TILE_FLOOR,
    MAP_TILE_WALL,
    MAP_TILE_WALL,
    MAP_TILE_WALL,
];

#[derive(Debug, Clone, Serialize, Deserialize)]
pub(crate) struct MazeRoomConfig {
    marker: String,
    width: i32,
    height: i32,
    min: i32,
    max: i32,
}

pub(crate) type MazeRoomConfigs = Vec<MazeRoomConfig>;

#[derive(Clone, Deserialize, Serialize, Debug)]
pub(crate) struct MazegenHauberkSettings {
    /// The type path for the area the maze is allowed to generate into.
    allowed_area: String,
    /// The turf that all floor cells will be turned into.
    default_floor: String,
    /// The submap insertion marker for 9x9 maps comprised of a horizontal
    /// hallway surrounded by walls.
    hallway_horizontal_marker: String,
    /// The submap insertion marker for 9x9 maps comprised of a vertical
    /// hallway surrounded by walls.
    hallway_vertical_marker: String,
    /// The submap insertion marker for 3x3 maps comprised of a section
    /// of hallway, with no guarantee of walls or floors on any side.
    hallway_node_marker: String,
    /// The chance that a hallway being grown will deviate from the direction
    /// it's taking and "wind" around.
    winding_percent: i32,
    /// The chance of adding a connector between two regions that have already
    /// been joined. Decreasing this leads to more loosely connected dungeons.
    extra_connector_chance: i32,
    /// The list of available maze room configurations. Each room configuration
    /// specifies its submap insertion marker, dimensions, and minimum and
    /// maximum requested number of rooms of this type generated.
    room_configs: MazeRoomConfigs,
}

type CellGrid = Vec<Vec<MapTileVal>>;

type RegionGrid = Vec<Vec<i8>>;

/// A struct representing the data used to procedurally generate a maze with the
/// "Hauberk" algorithm by Bob Nystrom described at
/// https://journal.stuffwithstuff.com/2014/12/21/rooms-and-mazes/ and
/// implemented in https://github.com/munificent/hauberk/ in Dart, with
/// inspiration from the pre-existing rust implementation implemented in
/// https://github.com/graysentinel/roguelike-rust/.
///
/// ## Details
///
/// When the mazegen mapmanip runs, it first marks out all the tiles it can
/// modify by checking to see if they have an area set to the `allowed_area`
/// setting. It scales the map down to a grid at 1/3rd size, and performs the
/// mazegen largely as described in Nystrom's post. It uses the passed in
/// `room_configs` as a list of possible room sizes and quantities to attempt to
/// spawn.
///
/// Once complete, each cell in the grid is converted to hallways and floors. If
/// the mapmanip finds a "straight" vertical or horizontal hallway comprised of
/// hallway cells along one axis, surrounded by wall cells, either the
/// `hallway_horizontal_marker` or `hallway_vertical_marker` submap markers are
/// inserted at the bottom left of the 3x3 area around the center cell being
/// checked. This means that the horizontal and vertical hallway markers are
/// given a 9x9 in-game tile area to work with, despite the hallway being either
/// 3x9 or 9x3. This gives mappers some leeway to expand the hallways a column
/// or row on either side, so long as they remain cognizant that these submap
/// insertions may overlap. For example, if you have two vertical hallway
/// markers, one right next to the other, the one on the left will share a 3x9
/// column of in-game turfs with the one on the right. As long as these submaps
/// do not extend too far out to each other, they can be cleverly used to expand
/// the areas that hallways take up.
///
/// The `hallway_node_marker` submap marker is used for nearly all hallway cells
/// that do not meet the above criteria for being part of a "straight" vertical
/// or horizontal hallway. This submap should be 3x3 tiles, and not anticipate
/// walls being on any of its sides.
///
/// ## JSON Config
///
/// A sample mapmanip configuration may look like this:
///
/// ```json
/// {
///     "type": "MazegenHauberk",
///     "allowed_area": "/area/mazegen",
///     "default_floor": "/turf/simulated/floor/plasteel",
///     "winding_percent": 20,
///     "extra_connector_chance": 20,
///     "hallway_horizontal_marker": "/obj/effect/map_effect/marker/mapmanip/submap/insert/deepmaints/hallway_horizontal",
///     "hallway_vertical_marker": "/obj/effect/map_effect/marker/mapmanip/submap/insert/deepmaints/hallway_vertical",
///     "hallway_node_marker": "/obj/effect/map_effect/marker/mapmanip/submap/insert/deepmaints/hallway_floor",
///     "room_configs": [
///         {
///             "marker": "/obj/effect/map_effect/marker/mapmanip/submap/insert/deepmaints/small",
///             "width": 3,
///             "height": 3,
///             "min": 7,
///             "max": 9
///         },
///         {
///             "marker": "/obj/effect/map_effect/marker/mapmanip/submap/insert/deepmaints/medium",
///             "width": 5,
///             "height": 5,
///             "min": 2,
///             "max": 3
///         }
///     ]
/// }
/// ```
///
/// ## Shortcomings
///
/// 1. Currently this mapmanip only works on the 1st z-level of a map file. This
///    isn't an impossible thing to fix, I just didn't feel like setting it up
///    to handle other z-levels.
/// 2. As a result of the mazegen algorithm using odd-sized rooms to ensure
///    consistent spacing for hallways and junctions, and the fact that the maze
///    is generated on a grid scaled to 1/3rd the original map size, all rooms
///    must have sides with dimensions that are both odd and multiples of three,
///    e.g. 9, 15, 21.
struct MazegenHauberk {
    settings: MazegenHauberkSettings,
    grid: CellGrid,
    width: i32,
    height: i32,
    regions: RegionGrid,
    rooms: Vec<Rect>,
    current_region: i8,
}

impl MazegenHauberk {
    fn new(settings: MazegenHauberkSettings, width: i32, height: i32) -> Self {
        MazegenHauberk {
            settings,
            width,
            height,

            grid: vec![vec![MAP_TILE_WALL; height as usize]; width as usize],
            regions: vec![vec![-1; height as usize]; width as usize],
            rooms: vec![],
            current_region: -1,
        }
    }

    fn can_place_room(&self, room: &Rect) -> bool {
        if self.rooms.iter().any(|other| room.intersects_with(other)) {
            return false;
        }

        for a in room.x1..room.x2 {
            for b in room.y1..room.y2 {
                let val = &self.grid[a as usize][b as usize];
                // positive values are other rooms
                if val == &MAP_TILE_IGNORE || val.0 >= 0 {
                    return false;
                }
            }
        }

        true
    }

    fn add_rooms(&mut self, rng: &mut impl Rng) {
        let mut room_config_idxes = vec![];
        for (idx, room_config) in self.settings.room_configs.iter().enumerate() {
            let room_type_count = rng.gen_range(room_config.min..=room_config.max);
            for _ in 0..room_type_count {
                room_config_idxes.push(idx);
            }
        }

        room_config_idxes.shuffle(rng);
        for _ in 0..=MAX_ROOM_PLACEMENT_TRIES {
            if room_config_idxes.is_empty() {
                break;
            }
            let idx = room_config_idxes.last().unwrap();
            let width = self.settings.room_configs[*idx].width;
            let height = self.settings.room_configs[*idx].height;
            let new_room = Rect::new(
                rng.gen_range(0..(self.width - width) / 2) * 2 + 1,
                rng.gen_range(0..(self.height - height) / 2) * 2 + 1,
                width,
                height,
            );
            if !self.can_place_room(&new_room) {
                continue;
            }

            self.create_room(new_room, *idx as i8);
            room_config_idxes.pop();
        }
    }

    fn connect_regions(&mut self, rng: &mut impl Rng) {
        let mut connector_regions = HashMap::new();

        for x in 1..self.width - 1 {
            for y in 1..self.height - 1 {
                if self.grid[x as usize][y as usize] != MAP_TILE_WALL {
                    continue;
                }

                let mut regions = HashSet::new();
                for d in DIRECTIONS.iter() {
                    let (dx, dy) = get_direction(d);
                    let region = self.regions[(x + dx) as usize][(y + dy) as usize];
                    if region != -1 {
                        regions.insert(region);
                    }
                }

                if regions.len() < 2 {
                    continue;
                }

                connector_regions.insert(Coord2::new(x, y), regions);
            }
        }

        let mut connectors: Vec<&Coord2> = connector_regions.keys().collect();

        let mut merged = HashMap::new();
        let mut open_regions = HashSet::new();

        for i in 0..=self.current_region {
            merged.insert(i, i);
            open_regions.insert(i);
        }

        while open_regions.len() > 1 && !connectors.is_empty() {
            let connector = connectors.choose(rng).unwrap();
            self.carve(connector);

            let regions: Vec<i8> = connector_regions[connector]
                .iter()
                .map(|region| merged[region])
                .collect();

            let dest = regions.first().unwrap();
            let sources: Vec<&i8> = regions[1..].iter().collect();

            for i in 0..=self.current_region {
                if sources.contains(&&merged[&i]) {
                    merged.insert(i, *dest);
                }
            }

            open_regions.retain(|&k| !sources.contains(&&k));

            connectors.retain(|pos| {
                if distance(connector.x - pos.x, connector.y - pos.y) < 2.0 {
                    return false;
                }

                let local_regions: HashSet<i8> =
                    HashSet::from_iter(connector_regions[pos].iter().map(|region| merged[region]));
                if local_regions.len() > 1 {
                    return true;
                }

                let new_junc = rng.gen_range(1..=100);
                if new_junc < self.settings.extra_connector_chance as u32 {
                    self.carve(pos);
                }
                false
            });
        }
    }

    fn remove_dead_ends(&mut self) {
        let mut done = false;

        while !done {
            done = true;

            for x in 0..self.width {
                for y in 0..self.height {
                    if self.grid[x as usize][y as usize] == MAP_TILE_WALL {
                        continue;
                    }

                    let mut exits = 0;
                    for d in DIRECTIONS.iter() {
                        let (dx, dy) = get_direction(d);
                        let (target_x, target_y) = (x + dx, y + dy);
                        if self.out_of_bounds(target_x, target_y) {
                            continue;
                        }
                        let val = &self.grid[target_x as usize][target_y as usize];
                        if val != &MAP_TILE_WALL && val != &MAP_TILE_IGNORE {
                            exits += 1;
                        }
                    }

                    if exits != 1 {
                        continue;
                    }

                    done = false;
                    self.grid[x as usize][y as usize] = MAP_TILE_WALL;
                }
            }
        }
    }

    fn can_carve(&self, pos: Coord2, d: &Directions) -> bool {
        let (dx, dy) = get_direction(d);
        let test_point = (pos.x + (dx * 3), pos.y + (dy * 3));
        if self.out_of_bounds(test_point.0, test_point.1) {
            return false;
        }

        let (target_x, target_y) = (pos.x + dx, pos.y + dy);

        self.grid[target_x as usize][target_y as usize] == MAP_TILE_WALL
    }

    fn start_region(&mut self) {
        self.current_region += 1;
    }

    fn carve(&mut self, pos: &Coord2) {
        self.grid[pos.x as usize][pos.y as usize] = MAP_TILE_FLOOR;
        self.regions[pos.x as usize][pos.y as usize] = self.current_region;
    }

    fn create_room(&mut self, room: Rect, idx: i8) {
        self.start_region();
        for x in room.x1..room.x2 {
            for y in room.y1..room.y2 {
                self.grid[x as usize][y as usize] = MAP_TILE_RESERVED_FLOOR;
                self.regions[x as usize][y as usize] = self.current_region;
            }
        }
        self.rooms.push(room);
        self.grid[room.x1 as usize][room.y1 as usize] = MapTileVal(idx);
    }

    /// Implementation of the "growing tree" algorithm from here:
    /// http://www.astrolog.org/labyrnth/algrithm.htm.
    fn grow_maze(&mut self, start: Coord2, rng: &mut impl Rng) {
        let mut cells = Vec::new();
        let mut last_dir = (0, 0);

        self.start_region();
        self.carve(&start);

        cells.push(start);

        while !cells.is_empty() {
            let cell = cells.last().unwrap();

            let mut unmade_cells = Vec::new();
            for d in DIRECTIONS.iter() {
                let (dx, dy) = get_direction(d);
                let target_pos = Coord2::new(cell.x + dx, cell.y + dy);
                if self.can_carve(target_pos, d) {
                    unmade_cells.push((dx, dy));
                }
            }

            if !unmade_cells.is_empty() {
                let dir = if unmade_cells.contains(&last_dir)
                    && rng.gen_range(1..=100) > self.settings.winding_percent as u32
                {
                    last_dir
                } else {
                    *unmade_cells.choose(rng).unwrap()
                };

                let close_pos = Coord2::new(cell.x + dir.0, cell.y + dir.1);
                let far_pos = Coord2::new(cell.x + (dir.0 * 2), cell.y + (dir.1 * 2));
                self.carve(&close_pos);
                self.carve(&far_pos);

                cells.push(far_pos);

                last_dir = dir;
            } else {
                cells.pop();
                last_dir = (0, 0);
            }
        }
    }

    /// Maze generation entry point.
    fn generate(&mut self, rng: &mut impl Rng) {
        self.add_rooms(rng);

        for y in (1..self.height).step_by(2) {
            for x in (1..self.width).step_by(2) {
                if self.grid[x as usize][y as usize] != MAP_TILE_WALL {
                    continue;
                }

                let start = Coord2::new(x, y);
                self.grow_maze(start, rng);
            }
        }

        self.connect_regions(rng);
        self.remove_dead_ends();
    }

    /// Get the grid values of the 3x3 cell area with (x, y) at the center.
    fn get_neighborhood(&self, x: i32, y: i32) -> Vec<MapTileVal> {
        let mut result = vec![];
        for dy in -1..=1 {
            for dx in -1..=1 {
                let x2 = x + dx;
                let y2 = y + dy;
                if x2 >= 0 && x2 < self.width && y2 >= 0 && y2 < self.height {
                    result.push(self.grid[x2 as usize][y2 as usize].clone());
                } else {
                    result.push(MAP_TILE_IGNORE);
                }
            }
        }

        result
    }

    fn out_of_bounds(&self, x: i32, y: i32) -> bool {
        x < 0 || x >= self.width || y < 0 || y >= self.height
    }
}

pub(crate) fn mapmanip_mazegen_hauberk(
    map: &mut GridMap,
    settings: &MazegenHauberkSettings,
) -> eyre::Result<()> {
    let width = map.size.x / SCALE;
    let height = map.size.y / SCALE;
    let mut rng = thread_rng();

    let mut data = MazegenHauberk::new(settings.clone(), width, height);

    // set up the grid to ignore any cells that aren't the correct /area type
    for x in 1..map.size.x {
        for y in 1..map.size.y {
            if let Some(tile) = map.grid.get(&Coord3::new(x, y, 1)) {
                if let Some(area) = tile.get_area() {
                    if !area.path.starts_with(&settings.allowed_area) {
                        data.grid[(x / SCALE) as usize][(y / SCALE) as usize] = MAP_TILE_IGNORE;
                    }
                }
            }
        }
    }

    // perform the maze generation
    data.generate(&mut rng);

    // take the generated maze results and apply them to the grid map,
    // adding submap markers, changing /turf paths, and marking cells
    // as reserved by hallway submaps.
    for x in 0..width {
        for y in 0..height {
            let root_val = &data.grid[x as usize][y as usize];
            if root_val.0 >= 0 {
                let root_tile = map
                    .grid
                    .get_mut(&Coord3::new((x * 3) + 1, (y * 3) + 1, 1))
                    .unwrap();
                root_tile.prefabs.push(Prefab::from_path(
                    settings.room_configs[root_val.0 as usize].marker.clone(),
                ));
                continue;
            }

            if !(root_val == &MAP_TILE_FLOOR || root_val == &MAP_TILE_RESERVED_FLOOR) {
                continue;
            }

            // look for solo connecting halls that are otherwise
            // filled in with walls and give them their own submap
            let neighborhood = data.get_neighborhood(x, y);
            if neighborhood == SAFE_HORIZONTAL_HALL {
                data.grid[x as usize][y as usize] = MAP_TILE_RESERVED_FLOOR;
                data.grid[(x + 2) as usize][y as usize] = MAP_TILE_RESERVED_FLOOR;
                let tile = map
                    .grid
                    .get_mut(&Coord3::new((x - 1) * 3 + 1, (y - 1) * 3 + 1, 1))
                    .unwrap();
                tile.prefabs
                    .retain(|prefab| !prefab.path.starts_with(MAPMANIP_MARKER_PREFIX));
                tile.prefabs
                    .insert(0, Prefab::from_path(&settings.hallway_horizontal_marker));
            } else if neighborhood == SAFE_VERTICAL_HALL {
                data.grid[x as usize][y as usize] = MAP_TILE_RESERVED_FLOOR;
                data.grid[x as usize][(y + 2) as usize] = MAP_TILE_RESERVED_FLOOR;
                let tile = map
                    .grid
                    .get_mut(&Coord3::new((x - 1) * 3 + 1, (y - 1) * 3 + 1, 1))
                    .unwrap();
                tile.prefabs
                    .retain(|prefab| !prefab.path.starts_with(MAPMANIP_MARKER_PREFIX));
                tile.prefabs
                    .insert(0, Prefab::from_path(&settings.hallway_vertical_marker));
            } else {
                data.grid[x as usize][y as usize] = MAP_TILE_FLOOR;
                let tile = map
                    .grid
                    .get_mut(&Coord3::new(x * 3 + 1, y * 3 + 1, 1))
                    .unwrap();
                tile.prefabs
                    .insert(0, Prefab::from_path(&settings.hallway_node_marker));
            }

            for a in (x * 3)..(x + 1) * 3 {
                for b in (y * 3)..(y + 1) * 3 {
                    let tile = map.grid.get_mut(&Coord3::new(a + 1, b + 1, 1)).unwrap();
                    tile.remove_turf().wrap_err("map tile has no turf")?;
                    tile.prefabs
                        .insert(0, Prefab::from_path(&settings.default_floor));
                }
            }
        }
    }

    Ok(())
}
