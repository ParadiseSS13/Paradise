import { map } from 'common/collections';
import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { Box, Button, Fragment, LabeledList, NumberInput, Section } from '../components';
import { RADIO_CHANNELS } from '../constants';
import { Window } from '../layouts';

export const Radio = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    freqlock,
    frequency,
    minFrequency,
    maxFrequency,
    canReset,
    listening,
    broadcasting,
    loudspeaker,
    has_loudspeaker,
  } = data;
  const tunedChannel = RADIO_CHANNELS.find((channel) => channel.freq === frequency);
  let matchedChannel = tunedChannel && tunedChannel.name ? true : false;
  let colorMap = [];
  let rc = [];
  let i = 0;
  for (i = 0; i < RADIO_CHANNELS.length; i++) {
    rc = RADIO_CHANNELS[i];
    colorMap[rc['name']] = rc['color'];
  }
  const schannels = map((value, key) => ({
    name: key,
    status: !!value,
  }))(data.schannels);
  const ichannels = map((value, key) => ({
    name: key,
    freq: value,
  }))(data.ichannels);
  return (
    <Window width={375} height={130 + schannels.length * 21.2 + ichannels.length * 11}>
      <Window.Content scrollable>
        <Section fill>
          <LabeledList>
            <LabeledList.Item label="Frequency">
              {(freqlock && (
                <Box inline color="light-gray">
                  {toFixed(frequency / 10, 1) + ' kHz'}
                </Box>
              )) || (
                <>
                  <NumberInput
                    animate
                    unit="kHz"
                    step={0.2}
                    stepPixelSize={10}
                    minValue={minFrequency / 10}
                    maxValue={maxFrequency / 10}
                    value={frequency / 10}
                    format={(value) => toFixed(value, 1)}
                    onChange={(e, value) =>
                      act('frequency', {
                        adjust: value - frequency / 10,
                      })
                    }
                  />
                  <Button
                    icon="undo"
                    content=""
                    disabled={!canReset}
                    tooltip="Reset"
                    onClick={() =>
                      act('frequency', {
                        tune: 'reset',
                      })
                    }
                  />
                </>
              )}
              {matchedChannel && (
                <Box inline color={tunedChannel.color} ml={2}>
                  [{tunedChannel.name}]
                </Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Audio">
              <Button
                textAlign="center"
                width="37px"
                icon={listening ? 'volume-up' : 'volume-mute'}
                selected={listening}
                color={listening ? '' : 'bad'}
                tooltip={listening ? 'Disable Incoming' : 'Enable Incoming'}
                onClick={() => act('listen')}
              />
              <Button
                textAlign="center"
                width="37px"
                icon={broadcasting ? 'microphone' : 'microphone-slash'}
                selected={broadcasting}
                tooltip={broadcasting ? 'Disable Hotmic' : 'Enable Hotmic'}
                onClick={() => act('broadcast')}
              />
              {!!has_loudspeaker && (
                <Button
                  ml={1}
                  icon="bullhorn"
                  selected={loudspeaker}
                  content="Loudspeaker"
                  tooltip={loudspeaker ? 'Disable Loudspeaker' : 'Enable Loudspeaker'}
                  onClick={() => act('loudspeaker')}
                />
              )}
            </LabeledList.Item>
            {schannels.length !== 0 && (
              <LabeledList.Item label="Keyed Channels">
                {schannels.map((channel) => (
                  <Box key={channel.name}>
                    <Button
                      icon={channel.status ? 'check-square-o' : 'square-o'}
                      selected={channel.status}
                      content=""
                      onClick={() =>
                        act('channel', {
                          channel: channel.name,
                        })
                      }
                    />
                    <Box inline color={colorMap[channel.name]}>
                      {channel.name}
                    </Box>
                  </Box>
                ))}
              </LabeledList.Item>
            )}
            {ichannels.length !== 0 && (
              <LabeledList.Item label="Standard Channel">
                {ichannels.map((channel) => (
                  <Button
                    key={'i_' + channel.name}
                    icon="arrow-right"
                    content={channel.name}
                    selected={matchedChannel && tunedChannel.name === channel.name}
                    onClick={() =>
                      act('ichannel', {
                        ichannel: channel.freq,
                      })
                    }
                  />
                ))}
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
