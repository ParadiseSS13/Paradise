pub enum Directions {
    North,
    South,
    East,
    West,
}

pub static DIRECTIONS: [Directions; 4] = [
    Directions::North,
    Directions::South,
    Directions::East,
    Directions::West,
];

#[derive(Clone, Copy, Debug)]
pub struct Rect {
    pub x1: i32,
    pub y1: i32,
    pub x2: i32,
    pub y2: i32,
}

impl Rect {
    pub fn new(x: i32, y: i32, w: i32, h: i32) -> Self {
        Rect {
            x1: x,
            y1: y,
            x2: x + w,
            y2: y + h,
        }
    }

    pub fn intersects_with(&self, other: &Rect) -> bool {
        (self.x1 <= other.x2)
            && (self.x2 >= other.x1)
            && (self.y1 <= other.y2)
            && (self.y2 >= other.y1)
    }
}

pub fn get_direction(d: &Directions) -> (i32, i32) {
    match d {
        Directions::North => (0, -1),
        Directions::South => (0, 1),
        Directions::East => (1, 0),
        Directions::West => (-1, 0),
    }
}

pub fn distance(dx: i32, dy: i32) -> f32 {
    ((dx.pow(2) + dy.pow(2)) as f32).sqrt()
}
