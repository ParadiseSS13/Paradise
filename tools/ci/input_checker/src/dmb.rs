#![allow(dead_code)]
use std::collections::HashMap;
use std::convert::TryInto;

pub type Result<T> = std::result::Result<T, String>;

struct Reader<'a> {
    data: &'a [u8],
    pos: usize,
    large: bool,
}

impl<'a> Reader<'a> {
    fn take(&mut self, len: usize) -> Result<&'a [u8]> {
        if self.data.len() - self.pos < len {
            return Err(format!(
                "the file ends at {:#x}, {len} more bytes wanted",
                self.pos
            ));
        }
        let slice = &self.data[self.pos..self.pos + len];
        self.pos += len;
        Ok(slice)
    }

    fn u8(&mut self) -> Result<u8> {
        Ok(self.take(1)?[0])
    }

    fn u16(&mut self) -> Result<u16> {
        Ok(u16::from_le_bytes(self.take(2)?.try_into().unwrap()))
    }

    fn u32(&mut self) -> Result<u32> {
        Ok(u32::from_le_bytes(self.take(4)?.try_into().unwrap()))
    }

    fn word(&mut self) -> Result<u32> {
        if self.large {
            self.u32()
        } else {
            self.u16().map(u32::from)
        }
    }

    fn words(&mut self, n: usize) -> Result<()> {
        for _ in 0..n {
            self.word()?;
        }
        Ok(())
    }

    fn object(&mut self) -> Result<Option<u32>> {
        let id = self.word()?;
        Ok(if id == 0xFFFF || id == 0xFFFF_FFFF {
            None
        } else {
            Some(id)
        })
    }
}

pub struct ProcRecord {
    pub path: Option<u32>,
    pub name: Option<u32>,
    pub bytecode: u32,
}

pub struct Instance {
    pub kind: u8,
    pub value: u32,
    pub init: Option<u32>,
}

pub struct Dmb {
    strings: Vec<Vec<u8>>,
    type_names: Vec<u32>,
    type_parents: Vec<Option<u32>>,
    pub type_vars: Vec<Option<u32>>,
    pub mob_types: Vec<u32>,
    miscs: Vec<Vec<u32>>,
    pub procs: Vec<ProcRecord>,
    pub proc_frames: Vec<(Option<u32>, Option<u32>)>,
    pub variable_names: Vec<u32>,
    pub instances: Vec<Instance>,
    resource_crcs: Option<Vec<u32>>,
    pub resource_names: Vec<(String, u32)>,
}

impl Dmb {
    pub fn load(data: &[u8]) -> Result<Dmb> {
        let (major, lhs, body) = header_lines(data)?;
        let mut r = Reader {
            data,
            pos: body,
            large: false,
        };
        let flags = r.u32()?;
        if flags & (1 << 31) != 0 {
            r.u32()?;
        }
        r.large = flags & (1 << 30) != 0;

        let cells = u64::from(r.u16()?) * u64::from(r.u16()?) * u64::from(r.u16()?);
        let mut left = cells;
        while left != 0 {
            r.words(3)?;
            let copies = r.u8()?;
            if copies == 0 {
                return Err(format!("a map cell at {:#x} has no copies", r.pos));
            }
            left = left.saturating_sub(u64::from(copies));
        }

        let string_bytes = r.u32()?;

        let type_count = r.word()?;
        let mut dmb = Dmb {
            strings: vec![],
            type_names: vec![],
            type_parents: vec![],
            type_vars: vec![],
            mob_types: vec![],
            miscs: vec![],
            procs: vec![],
            proc_frames: vec![],
            variable_names: vec![],
            instances: vec![],
            resource_crcs: None,
            resource_names: vec![],
        };
        for _ in 0..type_count {
            let (name, parent, vars) = read_type(&mut r, major, lhs)?;
            dmb.type_names.push(name);
            dmb.type_parents.push(parent);
            dmb.type_vars.push(vars);
        }

        for _ in 0..r.word()? {
            dmb.mob_types.push(r.word()?);
            r.object()?;
            if r.u8()? >= 0x80 {
                r.take(6)?;
            }
        }

        dmb.strings = read_strings(&mut r, major, string_bytes)?;

        for _ in 0..r.word()? {
            let n = r.u16()?;
            let mut entry = Vec::with_capacity(usize::from(n));
            for _ in 0..n {
                entry.push(r.word()?);
            }
            dmb.miscs.push(entry);
        }

        for _ in 0..r.word()? {
            let path = r.object()?;
            let name = r.object()?;
            r.object()?;
            r.object()?;
            r.take(2)?;
            if r.u8()? & 0x80 != 0 {
                r.take(5)?;
            }
            let bytecode = r.word()?;
            let locals = r.object()?;
            let params = r.object()?;
            dmb.procs.push(ProcRecord {
                path,
                name,
                bytecode,
            });
            dmb.proc_frames.push((locals, params));
        }

        for _ in 0..r.word()? {
            r.take(5)?;
            dmb.variable_names.push(r.word()?);
        }
        if major >= 512 && lhs >= 512 {
            r.u32()?;
        }

        let instances = (|| -> Result<Vec<Instance>> {
            let n = r.word()?;
            r.words(n as usize)?;
            let mut instances = vec![];
            for _ in 0..r.word()? {
                let kind = r.u8()?;
                let value = r.u32()?;
                let init = r.object()?;
                instances.push(Instance { kind, value, init });
            }
            Ok(instances)
        })();
        if let Ok(instances) = instances {
            dmb.instances = instances;
            dmb.resource_crcs = read_resources(&mut r, lhs).ok().flatten();
        }
        Ok(dmb)
    }

    pub fn string(&self, id: u32) -> Option<&[u8]> {
        self.strings.get(id as usize).map(Vec::as_slice)
    }

    pub fn strings(&self) -> &[Vec<u8>] {
        &self.strings
    }

    pub fn misc(&self, id: u32) -> Option<&[u32]> {
        self.miscs.get(id as usize).map(Vec::as_slice)
    }

    pub fn proc_path(&self, proc: &ProcRecord) -> Option<&[u8]> {
        self.string(proc.path?)
    }

    pub fn bytecode(&self, proc: &ProcRecord) -> &[u32] {
        &self.miscs[proc.bytecode as usize]
    }

    pub fn type_count(&self) -> usize {
        self.type_names.len()
    }

    pub fn type_path(&self, index: u32) -> Option<&[u8]> {
        self.string(*self.type_names.get(index as usize)?)
    }

    pub fn type_parent(&self, index: u32) -> Option<u32> {
        *self.type_parents.get(index as usize)?
    }

    pub fn variable_name(&self, id: u32) -> Option<&[u8]> {
        self.string(*self.variable_names.get(id as usize)?)
    }

    pub fn read_rsc(&mut self, rsc: &[u8]) {
        let Some(crcs) = &self.resource_crcs else {
            return;
        };
        let mut names: HashMap<u32, Vec<String>> = HashMap::new();
        let mut pos = 0;
        while pos + 4 <= rsc.len() {
            let len = u32::from_le_bytes(rsc[pos..pos + 4].try_into().unwrap()) as usize;
            let entry = &rsc[pos + 4..(pos + 5 + len).min(rsc.len())];
            pos += 5 + len;
            if entry.len() < 18 {
                continue;
            }
            let crc = u32::from_le_bytes(entry[2..6].try_into().unwrap());
            if let Some(end) = entry[18..].iter().position(|&b| b == 0) {
                let name = String::from_utf8_lossy(&entry[18..18 + end]).into_owned();
                names.entry(crc).or_default().push(name);
            }
        }
        self.resource_names = crcs
            .iter()
            .enumerate()
            .flat_map(|(id, crc)| {
                names
                    .get(crc)
                    .into_iter()
                    .flatten()
                    .map(move |n| (n.clone(), id as u32))
            })
            .collect();
    }

    pub fn resource_name(&self, id: u32) -> Option<&str> {
        self.resource_names
            .iter()
            .find(|(_, i)| *i == id)
            .map(|(n, _)| n.as_str())
    }
}

fn header_lines(data: &[u8]) -> Result<(u32, u32, usize)> {
    let bad = || "not a .dmb: no `world bin v` header".to_owned();
    let line = |from: usize| -> Result<(&str, usize)> {
        let end = from
            + data[from..]
                .iter()
                .position(|&b| b == b'\n')
                .ok_or_else(bad)?;
        Ok((
            std::str::from_utf8(&data[from..end]).map_err(|_| bad())?,
            end + 1,
        ))
    };
    let (first, next) = line(0)?;
    let major = first
        .strip_prefix("world bin v")
        .and_then(|v| v.parse().ok())
        .ok_or_else(bad)?;
    let (second, body) = line(next)?;
    let lhs = second
        .strip_prefix("min compatibility v")
        .and_then(|v| v.split(' ').next()?.parse().ok())
        .ok_or_else(bad)?;
    Ok((major, lhs, body))
}

fn read_type(r: &mut Reader, major: u32, lhs: u32) -> Result<(u32, Option<u32>, Option<u32>)> {
    let name = r.word()?;
    let parent = r.object()?;
    for _ in 0..4 {
        r.object()?;
    }
    r.u8()?;
    if major >= 307 && r.u8()? == 0x0F {
        r.u32()?;
    }
    r.object()?;
    if lhs >= 494 {
        r.object()?;
        r.take(4)?;
    }
    if lhs >= 508 {
        r.take(4)?;
    }
    r.object()?;
    if major >= 306 {
        r.u32()?;
        if lhs >= 514 {
            r.u32()?;
        }
    } else {
        r.u8()?;
    }
    r.object()?;
    r.object()?;
    r.object()?;
    r.object()?;
    let vars = r.object()?;
    if lhs >= 514 {
        r.object()?;
    }
    if major >= 267 {
        r.u32()?;
    }
    if lhs >= 500 && r.u8()? != 0 {
        r.take(24)?;
    }
    if lhs >= 509 && r.u8()? != 0 {
        r.take(80)?;
    }
    if major >= 306 {
        r.object()?;
    }
    Ok((name, parent, vars))
}

fn read_strings(r: &mut Reader, major: u32, expected_bytes: u32) -> Result<Vec<Vec<u8>>> {
    let count = r.word()?;
    let mut strings = Vec::with_capacity(count as usize);
    let mut hash: i32 = -1;
    let mut total = 0usize;
    for _ in 0..count {
        let at = r.pos as u16;
        let len = r.u16()? ^ at;
        if len == 0xFFFF {
            return Err("strings of 65535 bytes or more aren't read".to_owned());
        }
        let mut key = r.pos as u8;
        let text: Vec<u8> = r
            .take(usize::from(len))?
            .iter()
            .map(|b| {
                let b = b ^ key;
                key = key.wrapping_add(9);
                b
            })
            .collect();
        for &b in text.iter().chain([&0]) {
            hash = (hash << 8) ^ STRING_TABLE_CRC[(((hash >> 24) ^ i32::from(b)) & 0xFF) as usize];
        }
        total += text.len() + 1;
        strings.push(text);
    }
    if major >= 468 {
        let stored = r.u32()? as i32;
        if stored != hash {
            return Err(format!(
                "the string table's checksum is {hash:#x}, the file says {stored:#x}: the tables before it weren't read as \
                 this build wrote them"
            ));
        }
    }
    if total != expected_bytes as usize {
        return Err(format!(
            "the string table has {total} bytes, the header says {expected_bytes}"
        ));
    }
    Ok(strings)
}

fn read_resources(r: &mut Reader, lhs: u32) -> Result<Option<Vec<u32>>> {
    for _ in 0..r.u32()? {
        r.u16()?;
        r.word()?;
    }
    r.words(7)?;
    r.u32()?;
    r.words(2)?;
    if lhs > 514 {
        r.take(4)?;
    }
    r.take(5)?;
    r.word()?;
    let n = r.u16()?;
    r.words(usize::from(n))?;
    r.u16()?;
    r.words(2)?;
    r.take(10)?;
    r.words(5)?;
    r.take(6)?;
    let count = r.word()? as usize;
    let mut crcs = Vec::with_capacity(count);
    for _ in 0..count {
        crcs.push(r.u32()?);
        r.u8()?;
    }
    Ok((r.pos == r.data.len()).then_some(crcs))
}

#[rustfmt::skip]
static STRING_TABLE_CRC: [i32; 256] = [
    0, 0xaf, 0x15e, 0x1f1, 0x2bc, 0x213, 0x3e2, 0x34d, 0x578, 0x5d7, 0x426, 0x489, 0x7c4, 0x76b,
    0x69a, 0x635, 0xaf0, 0xa5f, 0xbae, 0xb01, 0x84c, 0x8e3, 0x912, 0x9bd, 0xf88, 0xf27, 0xed6,
    0xe79, 0xd34, 0xd9b, 0xc6a, 0xcc5, 0x15e0, 0x154f, 0x14be, 0x1411, 0x175c, 0x17f3, 0x1602,
    0x16ad, 0x1098, 0x1037, 0x11c6, 0x1169, 0x1224, 0x128b, 0x137a, 0x13d5, 0x1f10, 0x1fbf, 0x1e4e,
    0x1ee1, 0x1dac, 0x1d03, 0x1cf2, 0x1c5d, 0x1a68, 0x1ac7, 0x1b36, 0x1b99, 0x18d4, 0x187b, 0x198a,
    0x1925, 0x2bc0, 0x2b6f, 0x2a9e, 0x2a31, 0x297c, 0x29d3, 0x2822, 0x288d, 0x2eb8, 0x2e17, 0x2fe6,
    0x2f49, 0x2c04, 0x2cab, 0x2d5a, 0x2df5, 0x2130, 0x219f, 0x206e, 0x20c1, 0x238c, 0x2323, 0x22d2,
    0x227d, 0x2448, 0x24e7, 0x2516, 0x25b9, 0x26f4, 0x265b, 0x27aa, 0x2705, 0x3e20, 0x3e8f, 0x3f7e,
    0x3fd1, 0x3c9c, 0x3c33, 0x3dc2, 0x3d6d, 0x3b58, 0x3bf7, 0x3a06, 0x3aa9, 0x39e4, 0x394b, 0x38ba,
    0x3815, 0x34d0, 0x347f, 0x358e, 0x3521, 0x366c, 0x36c3, 0x3732, 0x379d, 0x31a8, 0x3107, 0x30f6,
    0x3059, 0x3314, 0x33bb, 0x324a, 0x32e5, 0x5780, 0x572f, 0x56de, 0x5671, 0x553c, 0x5593, 0x5462,
    0x54cd, 0x52f8, 0x5257, 0x53a6, 0x5309, 0x5044, 0x50eb, 0x511a, 0x51b5, 0x5d70, 0x5ddf, 0x5c2e,
    0x5c81, 0x5fcc, 0x5f63, 0x5e92, 0x5e3d, 0x5808, 0x58a7, 0x5956, 0x59f9, 0x5ab4, 0x5a1b, 0x5bea,
    0x5b45, 0x4260, 0x42cf, 0x433e, 0x4391, 0x40dc, 0x4073, 0x4182, 0x412d, 0x4718, 0x47b7, 0x4646,
    0x46e9, 0x45a4, 0x450b, 0x44fa, 0x4455, 0x4890, 0x483f, 0x49ce, 0x4961, 0x4a2c, 0x4a83, 0x4b72,
    0x4bdd, 0x4de8, 0x4d47, 0x4cb6, 0x4c19, 0x4f54, 0x4ffb, 0x4e0a, 0x4ea5, 0x7c40, 0x7cef, 0x7d1e,
    0x7db1, 0x7efc, 0x7e53, 0x7fa2, 0x7f0d, 0x7938, 0x7997, 0x7866, 0x78c9, 0x7b84, 0x7b2b, 0x7ada,
    0x7a75, 0x76b0, 0x761f, 0x77ee, 0x7741, 0x740c, 0x74a3, 0x7552, 0x75fd, 0x73c8, 0x7367, 0x7296,
    0x7239, 0x7174, 0x71db, 0x702a, 0x7085, 0x69a0, 0x690f, 0x68fe, 0x6851, 0x6b1c, 0x6bb3, 0x6a42,
    0x6aed, 0x6cd8, 0x6c77, 0x6d86, 0x6d29, 0x6e64, 0x6ecb, 0x6f3a, 0x6f95, 0x6350, 0x63ff, 0x620e,
    0x62a1, 0x61ec, 0x6143, 0x60b2, 0x601d, 0x6628, 0x6687, 0x6776, 0x67d9, 0x6494, 0x643b, 0x65ca,
    0x6565,
];
