# Main stuff

- Atmos control consoles need to be TGUI'd
- They also need to ditch signals and control the vents and stuff directly
- Linking of devices should just be a multitool job and save the UID
  - "You add [] to the multitool's buffer"
- Everything needs to use UIDs. No hard refs.
- Air alarms are pain
- Connect devices with an `id_tag` var and use initialize and lateinitialize to match
