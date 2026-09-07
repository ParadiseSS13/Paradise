import { Button, Dropdown, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const decisecondsToMinutes = 600;
const decisecondsToSeconds = 10;

const soundboardOptions = {
  horn: 'Air Horn',
  alert: 'Station Alert',
  siren: 'Warning Siren',
  honk: 'Honk',
  pump: 'Pump',
  pop: 'Pop',
  saber: 'Energy Sword',
  harm: 'Harm Alarm',
};

type DanceMachineProps = {
  active: boolean;
  selectedSong: string;
  songLength: number;
  charge: number;
  available: string[];
  onCooldown: boolean;
};

export const DanceMachine = (props, context) => {
  const { act, data } = useBackend<DanceMachineProps>();
  const { active, selectedSong, songLength, charge, available, onCooldown } = data;
  const songLengthMinutes = Math.floor(songLength / decisecondsToMinutes);
  const songLengthSeconds = Math.floor((songLength % decisecondsToMinutes) / decisecondsToSeconds);
  const chargesDisplayed = Math.floor(charge / 7);

  const soundboardButtons = Object.entries(soundboardOptions).map(([key, name]) => (
    <Button key={key} onClick={() => act(key)} disabled={chargesDisplayed < 1 || !active}>
      {name}
    </Button>
  ));

  return (
    <Window width={400} height={300}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section
              title={`Currently Selected: ${selectedSong} (${songLengthMinutes}:${String(songLengthSeconds).padStart(2, '0')})`}
            >
              <Dropdown
                placeholder="Select Track"
                selected={selectedSong}
                onSelected={(val) => act('select', { selectedSong: val })}
                disabled={active}
                options={available}
              />
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section
              title={`DJ's Soundboard - ${chargesDisplayed} ${chargesDisplayed === 1 ? 'Charge' : 'Charges'} Remaining`}
            >
              {soundboardButtons}
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section bold fill>
              {!active ? (
                <Button
                  height="100%"
                  verticalAlignContent="middle"
                  fluid
                  textAlign="center"
                  fontSize="min(8vw, 15vh)"
                  color="green"
                  disabled={onCooldown}
                  onClick={() => act('toggle')}
                >
                  {onCooldown ? 'REBOOTING...' : 'BREAK IT DOWN'}
                </Button>
              ) : (
                <Button
                  height="100%"
                  verticalAlignContent="middle"
                  fluid
                  textAlign="center"
                  fontSize="min(8vw, 15vh)"
                  color="red"
                  disabled={onCooldown}
                  onClick={() => act('toggle')}
                >
                  SHUT IT DOWN
                </Button>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
