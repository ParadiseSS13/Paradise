import { Box, Button, Collapsible, Dropdown, LabeledList, Modal, Section, Slider, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
export const Instrument = (properties) => {
  const { act, data } = useBackend();
  return (
    <Window width={600} height={505}>
      <InstrumentHelp />
      <Window.Content>
        <Stack fill vertical>
          <InstrumentStatus />
          <InstrumentEditor />
        </Stack>
      </Window.Content>
    </Window>
  );
};

const InstrumentHelp = (properties) => {
  const { act, data } = useBackend();
  const { help } = data;
  if (!help) {
    return;
  }
  return (
    <Modal maxWidth="75%" height={window.innerHeight * 0.75 + 'px'} mx="auto" py="0" px="0.5rem">
      <Section height="100%" title="Help" level="2" overflow="auto">
        <Box px="0.5rem" mt="-0.5rem">
          <h1>Making a Song</h1>
          <p>
            Lines are a series of chords, separated by commas&nbsp;
            <Box as="span" color="highlight">
              (,)
            </Box>
            , each with notes separated by hyphens&nbsp;
            <Box as="span" color="highlight">
              (-)
            </Box>
            .
            <br />
            Every note in a chord will play together, with the chord timed by the&nbsp;
            <Box as="span" color="highlight">
              tempo
            </Box>{' '}
            as defined above.
          </p>
          <p>
            Notes are played by the&nbsp;
            <Box as="span" color="good">
              names of the note
            </Box>
            , and optionally, the&nbsp;
            <Box as="span" color="average">
              accidental
            </Box>
            , and/or the{' '}
            <Box as="span" color="bad">
              octave number
            </Box>
            .
            <br />
            By default, every note is&nbsp;
            <Box as="span" color="average">
              natural
            </Box>{' '}
            and in&nbsp;
            <Box as="span" color="bad">
              octave 3
            </Box>
            . Defining a different state for either is remembered for each{' '}
            <Box as="span" color="good">
              note
            </Box>
            .
            <ul>
              <li>
                <Box as="span" color="highlight">
                  Example:
                </Box>
                &nbsp;
                <i>C,D,E,F,G,A,B</i> will play a&nbsp;
                <Box as="span" color="good">
                  C
                </Box>
                &nbsp;
                <Box as="span" color="average">
                  major
                </Box>{' '}
                scale.
              </li>
              <li>
                After a note has an&nbsp;
                <Box as="span" color="average">
                  accidental
                </Box>{' '}
                or&nbsp;
                <Box as="span" color="bad">
                  octave
                </Box>{' '}
                placed, it will be remembered:&nbsp;
                <i>C,C4,C#,C3</i> is <i>C3,C4,C4#,C3#</i>
              </li>
            </ul>
          </p>
          <p>
            <Box as="span" color="highlight">
              Chords
            </Box>
            &nbsp;can be played simply by seperating each note with a hyphen: <i>A-C#,Cn-E,E-G#,Gn-B</i>.<br />A{' '}
            <Box as="span" color="highlight">
              pause
            </Box>
            &nbsp;may be denoted by an empty chord: <i>C,E,,C,G</i>.
            <br />
            To make a chord be a different time, end it with /x, where the chord length will be length defined by&nbsp;
            <Box as="span" color="highlight">
              tempo / x
            </Box>
            ,&nbsp;
            <Box as="span" color="highlight">
              eg:
            </Box>{' '}
            <i>C,G/2,E/4</i>.
          </p>
          <p>
            Combined, an example line is: <i>E-E4/4,F#/2,G#/8,B/8,E3-E4/4</i>.
            <ul>
              <li>Lines may be up to 300 characters.</li>
              <li>A song may only contain up to 1,000 lines.</li>
            </ul>
          </p>
          <p>
            Lines are a series of chords, separated by commas&nbsp;
            <Box as="span" color="highlight">
              (,)
            </Box>
            , each with notes separated by hyphens&nbsp;
            <Box as="span" color="highlight">
              (-)
            </Box>
            .
            <br />
            Every note in a chord will play together, with the chord timed by the&nbsp;
            <Box as="span" color="highlight">
              tempo
            </Box>{' '}
            as defined above.
          </p>
          <p>
            Notes are played by the&nbsp;
            <Box as="span" color="good">
              names of the note
            </Box>
            , and optionally, the&nbsp;
            <Box as="span" color="average">
              accidental
            </Box>
            , and/or the{' '}
            <Box as="span" color="bad">
              octave number
            </Box>
            .
            <br />
            By default, every note is&nbsp;
            <Box as="span" color="average">
              natural
            </Box>{' '}
            and in&nbsp;
            <Box as="span" color="bad">
              octave 3
            </Box>
            . Defining a different state for either is remembered for each{' '}
            <Box as="span" color="good">
              note
            </Box>
            .
            <ul>
              <li>
                <Box as="span" color="highlight">
                  Example:
                </Box>
                &nbsp;
                <i>C,D,E,F,G,A,B</i> will play a&nbsp;
                <Box as="span" color="good">
                  C
                </Box>
                &nbsp;
                <Box as="span" color="average">
                  major
                </Box>{' '}
                scale.
              </li>
              <li>
                After a note has an&nbsp;
                <Box as="span" color="average">
                  accidental
                </Box>{' '}
                or&nbsp;
                <Box as="span" color="bad">
                  octave
                </Box>{' '}
                placed, it will be remembered:&nbsp;
                <i>C,C4,C#,C3</i> is <i>C3,C4,C4#,C3#</i>
              </li>
            </ul>
          </p>
          <p>
            <Box as="span" color="highlight">
              Chords
            </Box>
            &nbsp;can be played simply by seperating each note with a hyphen: <i>A-C#,Cn-E,E-G#,Gn-B</i>.<br />A{' '}
            <Box as="span" color="highlight">
              pause
            </Box>
            &nbsp;may be denoted by an empty chord: <i>C,E,,C,G</i>.
            <br />
            To make a chord be a different time, end it with /x, where the chord length will be length defined by&nbsp;
            <Box as="span" color="highlight">
              tempo / x
            </Box>
            ,&nbsp;
            <Box as="span" color="highlight">
              eg:
            </Box>{' '}
            <i>C,G/2,E/4</i>.
          </p>
          <p>
            Combined, an example line is: <i>E-E4/4,F#/2,G#/8,B/8,E3-E4/4</i>.
            <ul>
              <li>Lines may be up to 300 characters.</li>
              <li>A song may only contain up to 1,000 lines.</li>
            </ul>
          </p>
          <h1>Instrument Advanced Settings</h1>
          <ul>
            <li>
              <Box as="span" color="label">
                Type:
              </Box>
              &nbsp;Whether the instrument is legacy or synthesized.
              <br />
              Legacy instruments have a collection of sounds that are selectively used depending on the note to play.
              <br />
              Synthesized instruments use a base sound and change its pitch to match the note to play.
            </li>
            <li>
              <Box as="span" color="label">
                Current:
              </Box>
              &nbsp;Which instrument sample to play. Some instruments can be tuned to play different samples.
              Experiment!
            </li>
            <li>
              <Box as="span" color="label">
                Note Shift/Note Transpose:
              </Box>
              &nbsp;The pitch to apply to all notes of the song.
            </li>
            <li>
              <Box as="span" color="label">
                Sustain Mode:
              </Box>
              &nbsp;How a played note fades out.
              <br />
              Linear sustain means a note will fade out at a constant rate.
              <br />
              Exponential sustain means a note will fade out at an exponential rate, sounding smoother.
            </li>
            <li>
              <Box as="span" color="label">
                Volume Dropoff Threshold:
              </Box>
              &nbsp;The volume threshold at which a note is fully stopped.
            </li>
            <li>
              <Box as="span" color="label">
                Sustain indefinitely last held note:
              </Box>
              &nbsp;Whether the last note should be sustained indefinitely.
            </li>
          </ul>
          <Button color="grey" content="Close" onClick={() => act('help')} />
        </Box>
      </Section>
    </Modal>
  );
};

const InstrumentStatus = (properties) => {
  const { act, data } = useBackend();
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
      m={0}
      title="Instrument"
      buttons={
        <>
          <Button icon="info" content="Help" onClick={() => act('help')} />
          <Button icon="file" content="New" onClick={() => act('newsong')} />
          <Button icon="upload" content="Import" onClick={() => act('import')} />
        </>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Playback">
          <Button
            selected={playing}
            disabled={lines.length === 0 || repeat < 0}
            icon="play"
            content="Play"
            onClick={() => act('play')}
          />
          <Button disabled={!playing} icon="stop" content="Stop" onClick={() => act('stop')} />
        </LabeledList.Item>
        <LabeledList.Item label="Repeat">
          <Slider
            animated
            minValue={0}
            maxValue={maxRepeats}
            value={repeat}
            stepPixelSize={59}
            onChange={(e, v) =>
              act('repeat', {
                new: v,
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Tempo">
          <Box>
            <Button
              disabled={tempo >= maxTempo}
              content="-"
              as="span"
              mr="0.5rem"
              onClick={() =>
                act('tempo', {
                  new: tempo + tickLag,
                })
              }
            />
            {Math.round(600 / tempo)} BPM
            <Button
              disabled={tempo <= minTempo}
              content="+"
              as="span"
              ml="0.5rem"
              onClick={() =>
                act('tempo', {
                  new: tempo - tickLag,
                })
              }
            />
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Volume">
          <Slider
            animated
            minValue={minVolume}
            maxValue={maxVolume}
            value={volume}
            stepPixelSize={6}
            tickWhileDragging
            onChange={(e, v) =>
              act('setvolume', {
                new: v,
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Status">
          {ready ? <Box color="good">Ready</Box> : <Box color="bad">Instrument Definition Error!</Box>}
        </LabeledList.Item>
      </LabeledList>
      <InstrumentStatusAdvanced />
    </Section>
  );
};

const InstrumentStatusAdvanced = (properties) => {
  const { act, data } = useBackend();
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
        minValue={0.1}
        maxValue={5}
        value={sustainLinearDuration}
        step={0.5}
        stepPixelSize={85}
        format={(v) => Math.round(v * 100) / 100 + ' seconds'}
        onChange={(e, v) =>
          act('setlinearfalloff', {
            new: v / 10,
          })
        }
      />
    );
  } else if (sustainMode === 2) {
    smt = 'Exponential';
    modebody = (
      <Slider
        minValue={1.025}
        maxValue={10}
        value={sustainExponentialDropoff}
        step={0.01}
        format={(v) => Math.round(v * 1000) / 1000 + '% per decisecond'}
        onChange={(e, v) =>
          act('setexpfalloff', {
            new: v,
          })
        }
      />
    );
  }
  allowedInstrumentNames.sort();
  return (
    <Box my={-1}>
      <Collapsible mt="1rem" mb="0" title="Advanced">
        <Section mt={-1}>
          <LabeledList>
            <LabeledList.Item label="Type">{legacy ? 'Legacy' : 'Synthesized'}</LabeledList.Item>
            <LabeledList.Item label="Current">
              {instrumentLoaded ? (
                <Dropdown
                  options={allowedInstrumentNames}
                  selected={instrument}
                  width="50%"
                  onSelected={(v) =>
                    act('switchinstrument', {
                      name: v,
                    })
                  }
                />
              ) : (
                <Box color="bad">None!</Box>
              )}
            </LabeledList.Item>
            {!!(!legacy && canNoteShift) && (
              <>
                <LabeledList.Item label="Note Shift/Note Transpose">
                  <Slider
                    minValue={noteShiftMin}
                    maxValue={noteShiftMax}
                    value={noteShift}
                    stepPixelSize={2}
                    format={(v) => v + ' keys / ' + Math.round((v / 12) * 100) / 100 + ' octaves'}
                    onChange={(e, v) =>
                      act('setnoteshift', {
                        new: v,
                      })
                    }
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Sustain Mode">
                  <Dropdown
                    options={['Linear', 'Exponential']}
                    selected={smt}
                    mb="0.4rem"
                    onSelected={(v) =>
                      act('setsustainmode', {
                        new: v,
                      })
                    }
                  />
                  {modebody}
                </LabeledList.Item>
                <LabeledList.Item label="Volume Dropoff Threshold">
                  <Slider
                    animated
                    minValue={0.01}
                    maxValue={100}
                    value={sustainDropoffVolume}
                    stepPixelSize={6}
                    onChange={(e, v) =>
                      act('setdropoffvolume', {
                        new: v,
                      })
                    }
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Sustain indefinitely last held note">
                  <Button
                    selected={sustainHeldNote}
                    icon={sustainHeldNote ? 'toggle-on' : 'toggle-off'}
                    content={sustainHeldNote ? 'Yes' : 'No'}
                    onClick={() => act('togglesustainhold')}
                  />
                </LabeledList.Item>
              </>
            )}
          </LabeledList>
          <Button icon="redo" content="Reset to Default" mt="0.5rem" onClick={() => act('reset')} />
        </Section>
      </Collapsible>
    </Box>
  );
};

const InstrumentEditor = (properties) => {
  const { act, data } = useBackend();
  const { playing, lines, editing } = data;
  return (
    <Section
      fill
      scrollable
      title="Editor"
      buttons={
        <>
          <Button
            disabled={!editing || playing}
            icon="plus"
            content="Add Line"
            onClick={() =>
              act('newline', {
                line: lines.length + 1,
              })
            }
          />
          <Button selected={!editing} icon={editing ? 'chevron-up' : 'chevron-down'} onClick={() => act('edit')} />
        </>
      }
    >
      {!!editing &&
        (lines.length > 0 ? (
          <LabeledList>
            {lines.map((l, i) => (
              <LabeledList.Item
                key={i}
                label={i + 1}
                buttons={
                  <>
                    <Button
                      disabled={playing}
                      icon="pen"
                      onClick={() =>
                        act('modifyline', {
                          line: i + 1,
                        })
                      }
                    />
                    <Button
                      disabled={playing}
                      icon="trash"
                      onClick={() =>
                        act('deleteline', {
                          line: i + 1,
                        })
                      }
                    />
                  </>
                }
              >
                {l}
              </LabeledList.Item>
            ))}
          </LabeledList>
        ) : (
          <Box color="label">Song is empty.</Box>
        ))}
    </Section>
  );
};
