/* eslint-disable max-len */
import { Fragment } from 'inferno';
import { useBackend } from "../backend";
import { Box, Button, Collapsible, Dropdown, LabeledList, Modal, Section, Slider } from "../components";
import { Window } from "../layouts";
export const Instrument = (properties, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window>
      <InstrumentHelp />
      <Window.Content scrollable>
        <InstrumentStatus />
        <InstrumentEditor />
      </Window.Content>
    </Window>
  );
};

const InstrumentHelp = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    help,
  } = data;
  if (!help) {
    return;
  }
  return (
    <Modal maxWidth="75%" mx="auto" py="0" px="0.5rem">
      <Section title="Help" level="2">
        <Box px="0.5rem" mt="-0.5rem">
          <p>
            Lines are a series of chords, separated by commas <Box as="span" color="highlight">(,)</Box>, each with notes seperated by hyphens <Box as="span" color="highlight">(-)</Box>.
            <br />
            Every note in a chord will play together, with the chord timed by the <Box as="span" color="highlight">tempo</Box> as defined above.
          </p>
          <p>
            Notes are played by the <Box as="span" color="good">names of the note</Box>, and optionally, the <Box as="span" color="average">accidental</Box>, and/or the <Box as="span" color="bad">octave number</Box>.
            <br />
            By default, every note is <Box as="span" color="average">natural</Box> and in <Box as="span" color="bad">octave 3</Box>. Defining a different state for either is remembered for each <Box as="span" color="good">note</Box>.
            <ul>
              <li><Box as="span" color="highlight">Example:</Box> <i>C,D,E,F,G,A,B</i> will play a <Box as="span" color="good">C</Box> <Box as="span" color="average">major</Box> scale.</li>
              <li>After a note has an <Box as="span" color="average">accidental</Box> or <Box as="span" color="bad">octave</Box> placed, it will be remembered: <i>C,C4,C#,C3</i> is <i>C3,C4,C4#,C3#</i></li>
            </ul>
          </p>
          <p>
            <Box as="span" color="highlight">Chords</Box> can be played simply by seperating each note with a hyphon: <i>A-C#,Cn-E,E-G#,Gn-B</i>.<br />
            A <Box as="span" color="highlight">pause</Box> may be denoted by an empty chord: <i>C,E,,C,G</i>.
            <br />
            To make a chord be a different time, end it with /x, where the chord length will be length defined by <Box as="span" color="highlight">tempo / x</Box>, <Box as="span" color="highlight">eg:</Box> <i>C,G/2,E/4</i>.
          </p>
          <p>
            Combined, an example line is: <i>E-E4/4,F#/2,G#/8,B/8,E3-E4/4</i>.
            <ul>
              <li>Lines may be up to 50 characters.</li>
              <li>A song may only contain up to 50 lines.</li>
            </ul>
          </p>
          <Button
            color="grey"
            content="Close"
            onClick={() => act('help')}
          />
        </Box>
      </Section>
    </Modal>
  );
};

const InstrumentStatus = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    lines,
    playing,
    repeat,
    maxRepeats,
    tempo,
    minTempo,
    maxTempo,
    tickLag,
    volume,
    minVolume,
    maxVolume,
    ready,
  } = data;
  return (
    <Section
      title="Instrument"
      buttons={
        <Fragment>
          <Button
            icon="info"
            content="Help"
            onClick={() => act('help')}
          />
          <Button
            icon="file"
            content="New"
            onClick={() => act('newsong')}
          />
          <Button
            icon="upload"
            content="Import"
            onClick={() => act('import')}
          />
        </Fragment>
      }>
      <LabeledList>
        <LabeledList.Item label="Playback">
          <Button
            selected={playing}
            disabled={lines.length === 0 || repeat <= 0}
            icon="play"
            content="Play"
            onClick={() => act('play')}
          />
          <Button
            disabled={!playing}
            icon="stop"
            content="Stop"
            onClick={() => act('stop')}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Repeat">
          <Slider
            animated
            minValue="0"
            maxValue={maxRepeats}
            value={repeat}
            stepPixelSize="59"
            onChange={(_e, v) => act('repeat', {
              new: v,
            })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Tempo">
          <Box>
            <Button
              disabled={tempo >= maxTempo}
              content="-"
              as="span"
              mr="0.5rem"
              onClick={() => act('tempo', {
                new: tempo + tickLag,
              })}
            />
            {Math.round(600 / tempo)} BPM
            <Button
              disabled={tempo <= minTempo}
              content="+"
              as="span"
              ml="0.5rem"
              onClick={() => act('tempo', {
                new: tempo - tickLag,
              })}
            />
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Volume">
          <Slider
            animated
            minValue={minVolume}
            maxValue={maxVolume}
            value={volume}
            stepPixelSize="6"
            onChange={(_e, v) => act('setvolume', {
              new: v,
            })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Status">
          {ready ? (
            <Box color="good">
              Ready
            </Box>
          ) : (
            <Box color="bad">
              Instrument Definition Error!
            </Box>
          )}
        </LabeledList.Item>
      </LabeledList>
      <InstrumentStatusAdvanced />
    </Section>
  );
};

const InstrumentStatusAdvanced = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    allowedInstrumentNames,
    instrumentLoaded,
    instrument,
    canNoteShift,
    noteShift,
    noteShiftMin,
    noteShiftMax,
    sustainMode,
    sustainLinearDuration,
    sustainExponentialDropoff,
    legacy,
    sustainDropoffVolume,
    sustainHeldNote,
  } = data;
  let smt, modebody;
  if (sustainMode === 1) {
    smt = 'Linear';
    modebody = (
      <Slider
        minValue="0.1"
        maxValue="5"
        value={sustainLinearDuration}
        step="0.5"
        stepPixelSize="85"
        format={v => Math.round(v * 100) / 100 + " seconds"}
        onChange={(_e, v) => act('setlinearfalloff', {
          new: v / 10,
        })}
      />
    );
  } else if (sustainMode === 2) {
    smt = 'Exponential';
    modebody = (
      <Slider
        minValue="1.025"
        maxValue="10"
        value={sustainExponentialDropoff}
        step="0.01"
        format={v => Math.round(v * 1000) / 1000 + "% per decisecond"}
        onChange={(_e, v) => act('setexpfalloff', {
          new: v,
        })}
      />
    );
  }
  allowedInstrumentNames.sort();
  return (
    <Box my={-1}>
      <Collapsible mt="1rem" mb="0" title="Advanced">
        <Section mt={-1}>
          <LabeledList>
            <LabeledList.Item label="Type">
              {legacy ? "Legacy" : "Synthesized"}
            </LabeledList.Item>
            <LabeledList.Item label="Current">
              {instrumentLoaded ? (
                <Dropdown
                  options={allowedInstrumentNames}
                  selected={instrument}
                  width="40%"
                  onSelected={v => act('switchinstrument', {
                    name: v,
                  })}
                />
              ) : (
                <Box color="bad">
                  None!
                </Box>
              )}
            </LabeledList.Item>
            {!!(!legacy && canNoteShift) && (
              <Fragment>
                <LabeledList.Item label="Note Shift/Note Transpose">
                  <Slider
                    minValue={noteShiftMin}
                    maxValue={noteShiftMax}
                    value={noteShift}
                    stepPixelSize="2"
                    format={v => v + " keys / " + Math.round(v / 12 * 100) / 100 + " octaves"}
                    onChange={(_e, v) => act('setnoteshift', {
                      new: v,
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Sustain Mode">
                  <Dropdown
                    options={['Linear', 'Exponential']}
                    selected={smt}
                    onSelected={v => act('setsustainmode', {
                      new: v,
                    })}
                  />
                  {modebody}
                </LabeledList.Item>
                <LabeledList.Item label="Volume Dropoff Threshold">
                  <Slider
                    animated
                    minValue="0"
                    maxValue="100"
                    value={sustainDropoffVolume}
                    stepPixelSize="6"
                    onChange={(_e, v) => act('setdropoffvolume', {
                      new: v,
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Sustain indefinitely last held note">
                  <Button
                    selected={sustainHeldNote}
                    icon={sustainHeldNote ? "toggle-on" : "toggle-off"}
                    content={sustainHeldNote ? "Yes" : "No"}
                    onClick={() => act('togglesustainhold')}
                  />
                </LabeledList.Item>
              </Fragment>
            )}
          </LabeledList>
        </Section>
      </Collapsible>
    </Box>
  );
};

const InstrumentEditor = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    playing,
    lines,
    editing,
  } = data;
  return (
    <Section
      title="Editor"
      buttons={
        <Fragment>
          <Button
            disabled={!editing || playing}
            icon="plus"
            content="Add Line"
            onClick={() => act('newline', {
              line: lines.length + 1,
            })}
          />
          <Button
            selected={!editing}
            icon={editing ? "chevron-up" : "chevron-down"}
            onClick={() => act('edit')}
          />
        </Fragment>
      }>
      {!!editing && (
        lines.length > 0 ? (
          <LabeledList>
            {lines.map((l, i) => (
              <LabeledList.Item
                key={i}
                label={i + 1}
                buttons={(
                  <Fragment>
                    <Button
                      disabled={playing}
                      icon="pen"
                      onClick={() => act('modifyline', {
                        line: i + 1,
                      })}
                    />
                    <Button
                      disabled={playing}
                      icon="trash"
                      onClick={() => act('deleteline', {
                        line: i + 1,
                      })}
                    />
                  </Fragment>
                )}>
                {l}
              </LabeledList.Item>
            ))}
          </LabeledList>
        ) : (
          <Box color="label">
            Song is empty.
          </Box>
        )
      )}
    </Section>
  );
};
