//! Radiation waves.
//!
//! A wave spreads out a ring of tiles each SSradiation fire. The spreading maths is here, what's on
//! each tile and what the radiation does to it stays in BYOND.
//!
//! Each fire: `rad_waves_begin` lists the tiles to look at, `rad_waves_resolve` gives each wave's
//! strength on the ones with something on them, and `rad_waves_finish` moves the waves on.
use byondapi::prelude::*;
use eyre::eyre;
use std::collections::HashMap;
use std::sync::Mutex;

/// Waves stop at this. Must match RAD_BACKGROUND_RADIATION.
const RAD_BACKGROUND_RADIATION: f32 = 9.0;

struct Wave {
    /// What BYOND knows this wave by. Reused once the wave ends.
    id: u32,
    /// Top left corner of the square the wave has reached, from 1 like BYOND.
    x: i32,
    y: i32,
    z: i32,
    /// How many rings out the wave has got.
    steps: i32,
    /// The strength at the origin. A tile gets this times its weight.
    intensity: f32,
    /// The kind of radiation, as BYOND numbers them.
    emission: i32,
    /// The weights of the last ring's tiles, clockwise from the top left corner.
    weights: Vec<f32>,
    /// All of those added up.
    weight_sum: f32,
}

/// One tile a wave reaches this step.
struct RingTile {
    /// Where on the ring it is, from 1, clockwise from the top left corner.
    ring_index: usize,
    /// How much of the wave gets to it.
    weight: f32,
    /// Which of the tiles BYOND was asked about it is.
    ask: usize,
}

/// A wave's next ring, worked out but not taken yet.
struct PendingRing {
    /// Which wave, as an index into `waves`.
    wave: usize,
    tiles: Vec<RingTile>,
}

#[derive(Default)]
struct Waves {
    /// Every wave still spreading, oldest first.
    waves: Vec<Wave>,
    /// Ids of ended waves, to hand out again.
    free_ids: Vec<u32>,
    /// The highest id handed out so far.
    last_id: u32,
    /// This fire's rings, in the order BYOND deals with the waves.
    pending: Vec<PendingRing>,
    /// The tiles BYOND gets asked about this fire.
    asks: Vec<(i32, i32, i32, i32)>,
    /// The (ring, tile) of each strength handed out by resolve.
    hits: Vec<(usize, usize)>,
}

static WAVES: Mutex<Option<Waves>> = Mutex::new(None);

fn with_waves<T>(action: impl FnOnce(&mut Waves) -> T) -> T {
    let mut guard = WAVES.lock().unwrap();
    action(guard.get_or_insert_with(Waves::default))
}

impl Waves {
    fn start(&mut self, x: i32, y: i32, z: i32, intensity: f32, emission: i32, weight: f32) -> u32 {
        let id = self.free_ids.pop().unwrap_or_else(|| {
            self.last_id += 1;
            self.last_id
        });
        self.waves.push(Wave {
            id,
            x,
            y,
            z,
            steps: 0,
            intensity,
            emission,
            weights: vec![weight],
            weight_sum: weight,
        });
        id
    }

    /// Works out every wave's next ring. Returns the ids of the waves that have ended.
    fn begin(&mut self, max_x: i32, max_y: i32) -> Vec<u32> {
        // Start over if the last fire never finished.
        self.pending.clear();
        self.asks.clear();
        self.hits.clear();

        let mut ended = Vec::new();
        let free_ids = &mut self.free_ids;
        self.waves.retain(|wave| {
            // Too weak to do anything, or its corner has gone off the map.
            let over = wave.weight_sum * wave.intensity < RAD_BACKGROUND_RADIATION
                || wave.x - 1 < 1
                || wave.y + 1 > max_y;
            if over {
                ended.push(wave.id);
                free_ids.push(wave.id);
            }
            !over
        });

        let mut ask_lookup: HashMap<(i32, i32, i32, i32), usize> = HashMap::new();
        // BYOND goes through its waves newest first.
        for wave_index in (0..self.waves.len()).rev() {
            let wave = &self.waves[wave_index];
            // The ring starts from the corner up and left of the last one.
            let corner_x = wave.x - 1;
            let corner_y = wave.y + 1;
            let steps = wave.steps + 1;
            let edge_length = (2 * steps) as usize;
            let ring_length = (8 * steps) as usize;
            let ratio: f32 = if steps > 1 {
                (steps - 1) as f32 / steps as f32
            } else {
                1.0 / 8.0
            };
            let weight_length = wave.weights.len();
            let last_weight = |position: usize| wave.weights[(position - 1) % weight_length];
            // Going around the square stops for good at the edge of the map.
            let mut first_off_map = ring_length + 1;
            if corner_x + edge_length as i32 > max_x {
                first_off_map = (max_x - corner_x + 2) as usize;
            } else if corner_y - (edge_length as i32) < 1 {
                first_off_map = edge_length + corner_y as usize + 1;
            }

            let mut tiles = Vec::new();
            for i in 1..=ring_length {
                if i >= first_off_map {
                    break;
                }
                let edge = (i - 1) / edge_length;
                // Where we are along the edge we're on. Each corner starts a new edge.
                let index = i - edge * edge_length;
                let offset = edge * (edge_length - 2);
                // The tile behind this one on the last ring, and the ones either side of that.
                let weight_left = if index > 2 { last_weight(index + offset - 2) } else { 0.0 };
                let weight_center = if index > 1 { last_weight(index + offset - 1) } else { 0.0 };
                let weight_right = if index < edge_length { last_weight(index + offset) } else { 0.0 };
                let reaching = weight_left + weight_center + weight_right;
                if reaching == 0.0 {
                    continue;
                }
                let shares = 1
                    + (index > 1 && steps > 1) as i32
                    + (index > 2 && index < edge_length) as i32;
                let weight = ratio * reaching / shares as f32;
                let index = index as i32;
                let edge_length = edge_length as i32;
                // Clockwise from the top left corner: top, right, bottom, left.
                let (x, y) = match edge {
                    0 => (corner_x + index - 1, corner_y),
                    1 => (corner_x + edge_length, corner_y - index + 1),
                    2 => (corner_x + edge_length - index + 1, corner_y - edge_length),
                    _ => (corner_x, corner_y - edge_length + index - 1),
                };
                let key = (x, y, wave.z, wave.emission);
                let asks = &mut self.asks;
                let ask = *ask_lookup.entry(key).or_insert_with(|| {
                    asks.push(key);
                    asks.len() - 1
                });
                tiles.push(RingTile {
                    ring_index: i,
                    weight,
                    ask,
                });
            }
            self.pending.push(PendingRing {
                wave: wave_index,
                tiles,
            });
        }
        ended
    }

    /// Takes which asked tiles have something on them. Returns wave, tile and strength for each.
    fn resolve(&mut self, occupied: &[bool]) -> eyre::Result<Vec<(u32, usize, f32)>> {
        if occupied.len() != self.asks.len() {
            return Err(eyre!(
                "Got {} answers for {} tiles asked about.",
                occupied.len(),
                self.asks.len()
            ));
        }
        self.hits.clear();
        let mut strengths = Vec::new();
        for (ring_number, ring) in self.pending.iter().enumerate() {
            let id = self.waves[ring.wave].id;
            for (tile_number, tile) in ring.tiles.iter().enumerate() {
                if occupied[tile.ask] {
                    self.hits.push((ring_number, tile_number));
                    strengths.push((id, tile.ask + 1, tile.weight));
                }
            }
        }
        Ok(strengths)
    }

    /// Takes how much got through on each, and moves every wave on a ring.
    fn finish(&mut self, passed: &[f32]) -> eyre::Result<()> {
        if passed.len() != self.hits.len() {
            return Err(eyre!(
                "Got {} weights back for {} handed out.",
                passed.len(),
                self.hits.len()
            ));
        }
        for (hit, weight) in self.hits.iter().zip(passed.iter()) {
            self.pending[hit.0].tiles[hit.1].weight = *weight;
        }
        for ring in self.pending.drain(..) {
            let wave = &mut self.waves[ring.wave];
            wave.x -= 1;
            wave.y += 1;
            wave.steps += 1;
            let mut weights = vec![0.0; (8 * wave.steps) as usize];
            let mut weight_sum: f32 = 0.0;
            for tile in ring.tiles {
                // What's left only counts if it's more than background.
                if tile.weight * wave.intensity > RAD_BACKGROUND_RADIATION {
                    weights[tile.ring_index - 1] = tile.weight;
                    weight_sum += tile.weight;
                }
            }
            wave.weights = weights;
            wave.weight_sum = weight_sum;
        }
        self.asks.clear();
        self.hits.clear();
        Ok(())
    }
}

/// BYOND API for starting a wave. Returns its id.
#[byondapi::bind]
fn rad_wave_start(
    x: ByondValue,
    y: ByondValue,
    z: ByondValue,
    intensity: ByondValue,
    emission: ByondValue,
    weight: ByondValue,
) -> eyre::Result<ByondValue> {
    let id = with_waves(|waves| -> eyre::Result<u32> {
        Ok(waves.start(
            f32::try_from(x)? as i32,
            f32::try_from(y)? as i32,
            f32::try_from(z)? as i32,
            f32::try_from(intensity)?,
            f32::try_from(emission)? as i32,
            f32::try_from(weight)?,
        ))
    })?;
    Ok(ByondValue::from(id as f32))
}

/// BYOND API for the start of a fire. Returns the ended waves, then the tiles to look at.
#[byondapi::bind]
fn rad_waves_begin(max_x: ByondValue, max_y: ByondValue) -> eyre::Result<ByondValue> {
    let max_x = f32::try_from(max_x)? as i32;
    let max_y = f32::try_from(max_y)? as i32;
    let values = with_waves(|waves| {
        let ended = waves.begin(max_x, max_y);
        let mut values: Vec<ByondValue> = Vec::with_capacity(1 + ended.len() + waves.asks.len() * 4);
        values.push(ByondValue::from(ended.len() as f32));
        for id in ended {
            values.push(ByondValue::from(id as f32));
        }
        for (x, y, z, emission) in &waves.asks {
            values.push(ByondValue::from(*x as f32));
            values.push(ByondValue::from(*y as f32));
            values.push(ByondValue::from(*z as f32));
            values.push(ByondValue::from(*emission as f32));
        }
        values
    });
    Ok(values.as_slice().try_into()?)
}

/// BYOND API for which tiles from `rad_waves_begin` have something on them.
/// Returns wave, tile and strength for each wave reaching one of those.
#[byondapi::bind]
fn rad_waves_resolve(occupied: ByondValue) -> eyre::Result<ByondValue> {
    let mut flags = Vec::new();
    for value in occupied.get_list_values()? {
        flags.push(f32::try_from(value).unwrap_or(0.0) != 0.0);
    }
    let strengths = with_waves(|waves| waves.resolve(&flags))?;
    let mut values: Vec<ByondValue> = Vec::with_capacity(strengths.len() * 3);
    for (id, ask, weight) in strengths {
        values.push(ByondValue::from(id as f32));
        values.push(ByondValue::from(ask as f32));
        values.push(ByondValue::from(weight));
    }
    Ok(values.as_slice().try_into()?)
}

/// BYOND API for the end of a fire. Takes how much got through on each, and moves the waves on.
#[byondapi::bind]
fn rad_waves_finish(passed: ByondValue) -> eyre::Result<ByondValue> {
    let mut weights = Vec::new();
    for value in passed.get_list_values()? {
        weights.push(f32::try_from(value)?);
    }
    with_waves(|waves| waves.finish(&weights))?;
    Ok(ByondValue::null())
}

/// BYOND API for forgetting every wave.
#[byondapi::bind]
fn rad_waves_reset() -> eyre::Result<ByondValue> {
    *WAVES.lock().unwrap() = None;
    Ok(ByondValue::null())
}

#[cfg(test)]
mod tests {
    use super::*;

    /// A wave over empty floor: the first ring gets an eighth each, and nothing is lost.
    #[test]
    fn first_ring() {
        let mut waves = Waves::default();
        let id = waves.start(100, 100, 2, 800.0, 3, 1.0);
        assert_eq!(id, 1);
        assert!(waves.begin(255, 255).is_empty());
        assert_eq!(waves.asks.len(), 8);
        assert_eq!(waves.asks[0], (99, 101, 2, 3));
        assert_eq!(waves.asks[7], (99, 100, 2, 3));
        assert!(waves.resolve(&[false; 8]).unwrap().is_empty());
        waves.finish(&[]).unwrap();
        assert_eq!(waves.waves[0].weights, vec![0.125; 8]);
        assert_eq!(waves.waves[0].weight_sum, 1.0);
    }

    /// Something on a tile takes some of the wave, and BYOND's answer is what carries on.
    #[test]
    fn blocked_tile() {
        let mut waves = Waves::default();
        waves.start(100, 100, 2, 800.0, 3, 1.0);
        waves.begin(255, 255);
        let mut occupied = [false; 8];
        occupied[1] = true;
        let strengths = waves.resolve(&occupied).unwrap();
        assert_eq!(strengths, vec![(1, 2, 0.125)]);
        waves.finish(&[0.0]).unwrap();
        assert_eq!(waves.waves[0].weights[1], 0.0);
        assert_eq!(waves.waves[0].weight_sum, 0.875);
    }

    /// A weak wave ends, and its id gets used again.
    #[test]
    fn wave_ends() {
        let mut waves = Waves::default();
        waves.start(100, 100, 2, 80.0, 3, 1.0);
        // An eighth of 80 is over background, so the first ring happens.
        assert!(waves.begin(255, 255).is_empty());
        waves.resolve(&[false; 8]).unwrap();
        waves.finish(&[]).unwrap();
        // The second ring's tiles all get less than background, so nothing is left after it.
        assert!(waves.begin(255, 255).is_empty());
        let asked = waves.asks.len();
        waves.resolve(&vec![false; asked]).unwrap();
        waves.finish(&[]).unwrap();
        assert_eq!(waves.waves[0].weight_sum, 0.0);
        assert_eq!(waves.begin(255, 255), vec![1]);
        assert!(waves.waves.is_empty());
        assert_eq!(waves.start(5, 5, 1, 100.0, 1, 1.0), 1);
    }

    /// A wave whose corner would leave the map ends, like the BYOND one did.
    #[test]
    fn corner_off_map() {
        let mut waves = Waves::default();
        waves.start(1, 100, 2, 800.0, 3, 1.0);
        assert_eq!(waves.begin(255, 255), vec![1]);
    }
}
