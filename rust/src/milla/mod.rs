//! This is the MILLA atmospherics system, a successor to LINDA.
//! MILLA stands for Multi-threaded, Improved, Low-Level Atmospherics
//! (Or it's just a Psychonauts reference.)
//! Some folks have also taken to calling it funnymos, after the author, FunnyMan.
//!
//! MILLA takes the majority of atmos out of BYOND and puts it here, in Rust code.
//! It stores its own model of the air distribution, and BYOND will call in to view and make
//! adjustments, as well as to trigger atmos ticks.
mod api;
mod constants;
mod conversion;
mod model;
mod simulate;
mod statics;
mod tick;
