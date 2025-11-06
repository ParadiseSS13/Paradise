use std::collections::HashMap;

use core::map_to_string;
use core::to_grid_map;
use core::GridMap;
use core::TileGrid;

use byondapi::value::ByondValue;
use dmmtools::dmi::Dir;
use dmmtools::dmm::Coord3;
use dmmtools::dmm::Prefab;
use dreammaker::constants::Constant;
use eyre::eyre;
use eyre::Context;
use eyre::ContextCompat;
use itertools::Itertools;
use procgen::{MazegenHauberkSettings, mapmanip_mazegen_hauberk};
use rand::prelude::IteratorRandom;
use rand::seq::SliceRandom;
use serde::{Deserialize, Serialize};
use tools::extract_submap;
use tools::insert_submap;

use crate::logging::setup_panic_handler;

mod core;
mod procgen;
mod tools;

#[cfg(test)]
mod test;

/// A specific map transformation. Currently implemented transformations are
/// `SubmapExtractInsert`, which looks up matching markers in another DMM file
/// to replace the contents of the specified submap dimensions, and
/// `RandomOrientation`, which rotates the map 0, 90, 180, or 270 degrees,
/// performing specialized transformations for atoms which require it in order
/// to make sense when rotated.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "type")]
pub enum MapManipulation {
    SubmapExtractInsert {
        submap_size_x: i64,
        submap_size_y: i64,
        submap_size_z: i64,
        submaps_dmm: String,
        marker_extract: String,
        marker_insert: String,
        submaps_can_repeat: bool,
    },
    RandomOrientation,
    MazegenHauberk(MazegenHauberkSettings),
}

#[derive(Debug)]
enum MapRotation {
    None,
    Clockwise90,
    Clockwise180,
    Clockwise270,
}

pub fn mapmanip_config_parse(config_path: &std::path::Path) -> eyre::Result<Vec<MapManipulation>> {
    // read
    let config = std::fs::read_to_string(config_path)
        .wrap_err(format!("mapmanip config read err: {config_path:?}"))?;

    // strip comments
    // as the jsonc format is "json with comments"
    // but serde_json lib can only handle actual json
    let re = regex::Regex::new(r"\/\/.*")?;
    let config = re.replace_all(&config, "");

    // parse
    let config = serde_json::from_str::<Vec<MapManipulation>>(&config)
        .wrap_err(format!("mapmanip config json parse err: {config_path:?}"))?;

    Ok(config)
}

pub fn mapmanip(
    map_dir_path: &std::path::Path,
    map: dmmtools::dmm::Map,
    config: &[MapManipulation],
) -> eyre::Result<dmmtools::dmm::Map> {
    // convert to gridmap
    let mut map = to_grid_map(&map);
    let mut singleton_tags: Vec<Constant> = vec![];

    // go through all the manipulations in `.jsonc` config for this `.dmm`
    for (n, manipulation) in config.iter().enumerate() {
        // readable index for errors
        let n = n + 1;
        let config_len = config.len();

        match manipulation {
            MapManipulation::SubmapExtractInsert {
                submap_size_x,
                submap_size_y,
                submap_size_z,
                submaps_dmm,
                marker_extract,
                marker_insert,
                submaps_can_repeat,
            } => mapmanip_submap_extract_insert(
                map_dir_path,
                &mut map,
                *submap_size_x,
                *submap_size_y,
                *submap_size_z,
                submaps_dmm,
                marker_extract,
                marker_insert,
                *submaps_can_repeat,
                &mut singleton_tags,
            )
            .wrap_err(format!(
                "submap extract insert fail;
					submaps path: {submaps_dmm:?};
					markers: {marker_extract}, {marker_insert};"
            )),
            MapManipulation::RandomOrientation => {
                mapmanip_orientation_randomize(&mut map).wrap_err("randomize orientation failure")
            }
            MapManipulation::MazegenHauberk(settings) => {
                mapmanip_mazegen_hauberk(&mut map, settings)
            }
        }
        .wrap_err(format!("mapmanip fail; manip n is: {n}/{config_len}"))?;
    }

    core::to_dict_map(&map).wrap_err("failed on `to_dict_map`")
}

#[allow(clippy::too_many_arguments)]
fn mapmanip_submap_extract_insert(
    map_dir_path: &std::path::Path,
    map: &mut GridMap,
    submap_size_x: i64,
    submap_size_y: i64,
    submap_size_z: i64,
    submaps_dmm: &String,
    marker_extract: &String,
    marker_insert: &String,
    submaps_can_repeat: bool,
    singleton_tags: &mut Vec<Constant>,
) -> eyre::Result<()> {
    let submap_size = dmmtools::dmm::Coord3::new(
        submap_size_x.try_into().wrap_err("invalid submap_size_x")?,
        submap_size_y.try_into().wrap_err("invalid submap_size_y")?,
        submap_size_z.try_into().wrap_err("invalid submap_size_z")?,
    );

    // get the submaps map
    let submaps_dmm: std::path::PathBuf = submaps_dmm.into();
    let submaps_dmm = map_dir_path.join(submaps_dmm);
    let submaps_map = GridMap::from_file(&submaps_dmm)
        .wrap_err(format!("can't read and parse submap dmm: {submaps_dmm:?}"))?;

    let mut marker_lookup: HashMap<Coord3, &Prefab> = Default::default();
    // find all the submap extract markers
    for (coord, tile) in submaps_map.grid.iter() {
        tile.prefabs.iter().for_each(|p| {
            if p.path == *marker_extract {
                marker_lookup.insert(coord, p);
            }
        });
    }
    if marker_lookup.is_empty() {
        return Err(eyre!("marker lookup empty for submap {submaps_dmm:?}"));
    }

    // find all the insert markers
    let mut marker_insert_coords = vec![];
    for (coord, tile) in map.grid.iter() {
        if tile.prefabs.iter().any(|p| p.path == *marker_insert) {
            marker_insert_coords.push(coord);
        }
    }

    // do all the extracts-inserts
    for insert_coord in marker_insert_coords {
        // pick a submap
        let (&extract_coord, &extract_prefab) = marker_lookup
            .iter()
            .filter(|(_, &prefab)| {
                !singleton_tags
                    .contains(prefab.vars.get("singleton_id").unwrap_or(Constant::null()))
            })
            .choose(&mut rand::thread_rng())
            .wrap_err(format!(
                "no extractions found for marker {marker_extract}, singletons={singleton_tags:?}"
            ))?;

        // if submaps should not be repeating, remove this one
        if !submaps_can_repeat {
            marker_lookup.remove(&extract_coord);
        }

        // extract that submap from the submap dmm
        let extracted = extract_submap(&submaps_map, extract_coord, submap_size)
            .wrap_err(format!("submap extraction failed; from {extract_coord}"))?;

        // and insert the submap into the manipulated map
        insert_submap(&extracted, insert_coord, map)
            .wrap_err(format!("submap insertion failed; at {insert_coord}"))?;

        let singleton_id = extract_prefab
            .vars
            .get("singleton_id")
            .unwrap_or(Constant::null());
        if !singleton_id.is_null() {
            singleton_tags.push(singleton_id.clone());
        }
    }

    Ok(())
}

fn rotate_direction(dir_i: i32, rotation: &MapRotation) -> i32 {
    let dir = Dir::from_int(dir_i).unwrap_or(Dir::South);
    match rotation {
        MapRotation::None => dir_i,
        MapRotation::Clockwise90 => dir.clockwise_90().to_int(),
        MapRotation::Clockwise180 => dir.flip().to_int(),
        MapRotation::Clockwise270 => dir.counterclockwise_90().to_int(),
    }
}

fn rotate_cable(dir_i: i32, rotation: &MapRotation) -> i32 {
    if dir_i == 0 {
        return 0;
    }
    let dir = Dir::from_int(dir_i).unwrap_or(Dir::South);
    match rotation {
        MapRotation::None => dir_i,
        MapRotation::Clockwise90 => dir.clockwise_90().to_int(),
        MapRotation::Clockwise180 => dir.flip().to_int(),
        MapRotation::Clockwise270 => dir.counterclockwise_90().to_int(),
    }
}

fn directional_rotate(path: String, rotation: &MapRotation) -> String {
    match rotation {
        MapRotation::None => path,
        MapRotation::Clockwise90 => {
            if path.ends_with("/north") {
                path.replace("/north", "/east")
            } else if path.ends_with("/south") {
                path.replace("/south", "/west")
            } else if path.ends_with("/east") {
                path.replace("/east", "/south")
            } else if path.ends_with("/west") {
                path.replace("/west", "/north")
            } else if path.ends_with("/northeast") {
                path.replace("/northeast", "/southeast")
            } else if path.ends_with("/northwest") {
                path.replace("/northwest", "/northeast")
            } else if path.ends_with("/southeast") {
                path.replace("/southeast", "/southwest")
            } else if path.ends_with("/southwest") {
                path.replace("/southwest", "/northwest")
            } else {
                path
            }
        }
        MapRotation::Clockwise180 => {
            if path.ends_with("/north") {
                path.replace("/north", "/south")
            } else if path.ends_with("/south") {
                path.replace("/south", "/north")
            } else if path.ends_with("/east") {
                path.replace("/east", "/west")
            } else if path.ends_with("/west") {
                path.replace("/west", "/east")
            } else if path.ends_with("/northeast") {
                path.replace("/northeast", "/southwest")
            } else if path.ends_with("/northwest") {
                path.replace("/northwest", "/southeast")
            } else if path.ends_with("/southeast") {
                path.replace("/southeast", "/northwest")
            } else if path.ends_with("/southwest") {
                path.replace("/southwest", "/northeast")
            } else {
                path
            }
        }
        MapRotation::Clockwise270 => {
            if path.ends_with("/north") {
                path.replace("/north", "/west")
            } else if path.ends_with("/south") {
                path.replace("/south", "/east")
            } else if path.ends_with("/east") {
                path.replace("/east", "/north")
            } else if path.ends_with("/west") {
                path.replace("/west", "/south")
            } else if path.ends_with("/northeast") {
                path.replace("/northeast", "/northwest")
            } else if path.ends_with("/northwest") {
                path.replace("/northwest", "/southwest")
            } else if path.ends_with("/southeast") {
                path.replace("/southeast", "/northeast")
            } else if path.ends_with("/southwest") {
                path.replace("/southwest", "/southeast")
            } else {
                path
            }
        }
    }
}

fn rotation_radians(rotation: &MapRotation) -> f32 {
    match rotation {
        MapRotation::None => 0f32.to_radians(),
        MapRotation::Clockwise90 => 90f32.to_radians(),
        MapRotation::Clockwise180 => 180f32.to_radians(),
        MapRotation::Clockwise270 => 270f32.to_radians(),
    }
}

fn rotation_coords(coord: Coord3, map_size: &Coord3, rotation: &MapRotation) -> Coord3 {
    match rotation {
        MapRotation::None => coord,
        MapRotation::Clockwise90 => Coord3 {
            x: coord.y,
            y: map_size.x - coord.x + 1,
            z: coord.z,
        },
        MapRotation::Clockwise180 => Coord3 {
            x: map_size.x - coord.x + 1,
            y: map_size.y - coord.y + 1,
            z: coord.z,
        },
        MapRotation::Clockwise270 => Coord3 {
            x: map_size.y - coord.y + 1,
            y: coord.x,
            z: coord.z,
        },
    }
}

fn rotation_size(size: Coord3, rotation: &MapRotation) -> Coord3 {
    match rotation {
        MapRotation::None => size,
        MapRotation::Clockwise90 => Coord3 {
            x: size.y,
            y: size.x,
            z: size.z,
        },
        MapRotation::Clockwise180 => size,
        MapRotation::Clockwise270 => Coord3 {
            x: size.y,
            y: size.x,
            z: size.z,
        },
    }
}

fn mapmanip_orientation_randomize(map: &mut GridMap) -> eyre::Result<()> {
    let rotation = [
        MapRotation::None,
        MapRotation::Clockwise90,
        MapRotation::Clockwise180,
        MapRotation::Clockwise270,
    ]
    .choose(&mut rand::thread_rng())
    .unwrap();

    if let MapRotation::None = rotation {
        return Ok(());
    }

    let new_coord = rotation_size(map.size, rotation);
    let mut new_map: GridMap = GridMap {
        size: new_coord,
        grid: TileGrid::new(new_coord.x, new_coord.y, new_coord.z),
    };

    for t in map.grid.values_mut() {
        t.prefabs.iter_mut().for_each(|f| {
            if f.path.contains("/directional/") || f.path.contains("/offset/") {
                f.path = directional_rotate(f.path.to_string(), rotation);
            } else if f.path.starts_with("/obj/structure/cable") {
                let cable_dirs = f
                    .vars
                    .get("icon_state")
                    .unwrap_or(&Constant::String("0-1".into()))
                    .as_str()
                    .unwrap()
                    .split('-')
                    .map(|f| {
                        f.parse::<i32>()
                            .unwrap_or_else(|_| panic!("Bad cable icon: {}", f))
                    })
                    .map(|f| rotate_cable(f, rotation))
                    .sorted()
                    .join("-");
                f.vars.insert(
                    "icon_state".to_string(),
                    Constant::String(cable_dirs.into()),
                );
            } else {
                let dir = f
                    .vars
                    .get("dir")
                    .unwrap_or(&Constant::Float(2.0f32))
                    .to_int()
                    .unwrap();
                f.vars.insert(
                    "dir".to_string(),
                    Constant::Float(rotate_direction(dir, rotation) as f32),
                );

                let pixel_x = f
                    .vars
                    .get("pixel_x")
                    .unwrap_or(&Constant::Float(0f32))
                    .to_int()
                    .unwrap();
                let pixel_y = f
                    .vars
                    .get("pixel_y")
                    .unwrap_or(&Constant::Float(0f32))
                    .to_int()
                    .unwrap();
                if pixel_x != 0 || pixel_y != 0 {
                    let rads = rotation_radians(rotation);
                    f.vars.insert(
                        "pixel_x".to_string(),
                        Constant::Float(
                            ((pixel_x as f32) * rads.cos() + (pixel_y as f32) * rads.sin()).round(),
                        ),
                    );
                    f.vars.insert(
                        "pixel_y".to_string(),
                        Constant::Float(
                            ((-pixel_x as f32) * rads.sin() + (pixel_y as f32) * rads.cos())
                                .round(),
                        ),
                    );
                }
            }
        });
    }

    for (coord, tile) in map.grid.iter() {
        new_map
            .grid
            .insert(&rotation_coords(coord, &map.size, rotation), tile.clone());
    }

    *map = new_map;
    Ok(())
}

///
#[byondapi::bind]
fn mapmanip_read_dmm_file(path: ByondValue) -> eyre::Result<ByondValue> {
    internal_mapmanip_read_dmm_file(path)
}

pub(crate) fn internal_mapmanip_read_dmm_file(path: ByondValue) -> eyre::Result<ByondValue> {
    setup_panic_handler();

    let path: std::path::PathBuf = path
        .get_string()
        .wrap_err(format!("path arg is not a string: {:?}", path))?
        .into();

    // just return null if path is bad for whatever reason
    if !path.is_file() || !path.exists() {
        return Ok(ByondValue::null());
    }

    // read file and parse with spacemandmm
    let mut dmm = dmmtools::dmm::Map::from_file(&path).wrap_err(format!(
        "spacemandmm parsing error; dmm file path: {path:?}; see error from spacemandmm below for more information"
    ))?;

    // do mapmanip if defined for this dmm
    let path_mapmanip_config = {
        let mut p = path.clone();
        p.set_extension("jsonc");
        p
    };
    if path_mapmanip_config.exists() {
        // get path for dir of this dmm
        let path_dir = path.parent().wrap_err("no parent")?;
        // parse config
        let config = crate::mapmanip::mapmanip_config_parse(&path_mapmanip_config).wrap_err(
            format!("config parse fail; path: {:?}", path_mapmanip_config),
        )?;
        // do actual map manipulation
        dmm = crate::mapmanip::mapmanip(path_dir, dmm, &config)
            .wrap_err(format!("mapmanip fail; dmm file path: {path:?}"))?;
    }

    // convert the map back to a string
    let dmm = crate::mapmanip::core::map_to_string(&dmm).wrap_err(format!(
        "error in converting map back to string; dmm file path: {path:?}"
    ))?;

    // and return it
    Ok(ByondValue::new_str(dmm)?)
}

/// To be used by the `tools/rustlib_tools/mapmanip.ps1` script.
/// Not to be called from the game server, so bad error-handling is fine.
/// This should run map manipulations on every `.dmm` map that has a `.jsonc` config file,
/// and write it to a `.mapmanipout.dmm` file in the same location.
#[no_mangle]
pub unsafe extern "C" fn all_mapmanip_configs_execute_ffi() {
    all_mapmanip_configs_execute("./_maps".into());
}

fn all_mapmanip_configs_execute(root_path: String) {
    let mapmanip_configs = walkdir::WalkDir::new(root_path)
        .into_iter()
        .map(|d| d.unwrap().path().to_owned())
        .filter(|p| p.extension().is_some())
        .filter(|p| p.extension().unwrap() == "jsonc")
        .collect_vec();
    assert_ne!(mapmanip_configs.len(), 0);

    for config_path in mapmanip_configs {
        let dmm_path = {
            let mut p = config_path.clone();
            p.set_extension("dmm");
            p
        };

        let path_dir: &std::path::Path = dmm_path.parent().unwrap();

        let mut dmm = dmmtools::dmm::Map::from_file(&dmm_path).unwrap();

        let config = crate::mapmanip::mapmanip_config_parse(&config_path).unwrap();

        dmm = crate::mapmanip::mapmanip(path_dir, dmm, &config).unwrap();

        let dmm = map_to_string(&dmm).unwrap();

        let dmm_out_path = {
            let mut p = dmm_path.clone();
            p.set_extension("mapmanipout.dmm");
            p
        };
        std::fs::write(dmm_out_path, dmm).unwrap();
    }
}
