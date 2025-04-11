pub mod to_dict_map;
pub use to_dict_map::to_dict_map;
pub mod to_grid_map;
pub use to_grid_map::to_grid_map;

pub mod map_to_string;
pub use map_to_string::map_to_string;

use eyre::Context;

use dmmtools::dmm;
use dmmtools::dmm::Coord3;

/// A representation of a single tile on a map that may or may not be mapped to an existing key.
#[derive(Clone, Debug, Default)]
pub struct Tile {
    /// A key temporarily assigned to the tile until an appropriate new/existing
    /// key can be assigned to it, or if it is already being used by a different
    /// prefab list in the file.
    pub key_suggestion: dmm::Key,
    /// The prefabs on the tile.
    pub prefabs: Vec<dmm::Prefab>,
}

impl Tile {
    /// Return the first /area that exists in the prefab.
    pub fn get_area(&self) -> Option<&dmm::Prefab> {
        self.prefabs
            .iter()
            .find(|prefab| prefab.path.starts_with("/area/"))
    }

    /// Remove and return the first /area that exists in the prefab.
    pub fn remove_area(&mut self) -> Option<dmm::Prefab> {
        let area = self.get_area().cloned();
        if area.is_some() {
            self.prefabs
                .retain(|prefab| !prefab.path.starts_with("/area/"))
        }
        area
    }

    /// Return the first /turf that exists in the prefab.
    pub fn get_turf(&self) -> Option<&dmm::Prefab> {
        self.prefabs
            .iter()
            .find(|prefab| prefab.path.starts_with("/turf/"))
    }

    /// Remove and return the first /turf that exists in the prefab.
    pub fn remove_turf(&mut self) -> Option<dmm::Prefab> {
        let turf = self.get_turf().cloned();
        if turf.is_some() {
            self.prefabs
                .retain(|prefab| !prefab.path.starts_with("/turf/"))
        }
        turf
    }
}

/// Thin abstraction over a flat vec, to provide a simple hashmap-like interface,
/// and to translate between 3D dmm coords (start at 1), and 1D flat vec coords (start at 0).
/// The translation is so that it looks better in logs/errors/etc,
/// where shown coords would correspond to coords seen in game or in strongdmm.
#[derive(Clone, Debug)]
pub struct TileGrid {
    pub size: Coord3,
    pub grid: Vec<crate::mapmanip::core::Tile>,
}

impl TileGrid {
    pub fn new(size_x: i32, size_y: i32, size_z: i32) -> TileGrid {
        Self {
            size: Coord3::new(size_x, size_y, size_z),
            grid: vec![Tile::default(); (size_x * size_y * size_z) as usize],
        }
    }

    pub fn len(&self) -> usize {
        self.grid.len()
    }

    fn coord_to_index(&self, coord: &Coord3) -> usize {
        let coord = Coord3::new(coord.x - 1, coord.y - 1, coord.z - 1);
        ((coord.x) + (coord.y * self.size.x) + (coord.z * self.size.x * self.size.y)) as usize
    }

    fn index_to_coord(&self, index: usize) -> Coord3 {
        let index = index as i32;
        Coord3::new(
            (index % self.size.x) + 1,
            ((index / self.size.x) % self.size.y) + 1,
            (index / (self.size.x * self.size.y)) + 1,
        )
    }

    pub fn get_mut(&mut self, coord: &Coord3) -> Option<&mut Tile> {
        let index = self.coord_to_index(coord);
        self.grid.get_mut(index)
    }

    pub fn get(&self, coord: &Coord3) -> Option<&Tile> {
        self.grid.get(self.coord_to_index(coord))
    }

    pub fn insert(&mut self, coord: &Coord3, tile: Tile) {
        *self.get_mut(coord).unwrap() = tile;
    }

    pub fn iter(&self) -> impl Iterator<Item = (Coord3, &Tile)> {
        self.grid
            .iter()
            .enumerate()
            .map(|(i, t)| (self.index_to_coord(i), t))
    }

    #[allow(dead_code)]
    pub fn keys(&self) -> impl Iterator<Item = Coord3> + '_ {
        self.grid
            .iter()
            .enumerate()
            .map(|(i, _t)| self.index_to_coord(i))
    }

    pub fn values(&self) -> impl Iterator<Item = &Tile> {
        self.grid.iter()
    }

    pub fn values_mut(&mut self) -> impl Iterator<Item = &mut Tile> {
        self.grid.iter_mut()
    }
}

/// This is analogous to `dmmtools::dmm::Map`, but instead of being structured like dmm maps are,
/// where they have a dictionary of keys-to-prefabs and a separate grid of keys,
/// this is only a direct coord-to-prefab grid.
/// It is not memory efficient, but it allows for much greater flexibility of manipulation.
#[derive(Clone, Debug)]
pub struct GridMap {
    /// The x, y, and z dimensions of the map.
    pub size: dmm::Coord3,
    /// The key-value data of the map in TileGrid format.
    pub grid: crate::mapmanip::core::TileGrid,
}

impl GridMap {
    pub fn from_file(path: &std::path::Path) -> eyre::Result<GridMap> {
        Ok(to_grid_map(
            &dmm::Map::from_file(path).wrap_err("failure to read from dmm parser")?,
        ))
    }
}
