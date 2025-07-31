import { map } from 'common/collections';
import { Box, Button, LabeledList, NumberInput, Section } from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { RADIO_CHANNELS } from '../constants';
import { Window } from '../layouts';

type RadioData = {
  freqlock: BooleanLike;
  frequency: number;
  minFrequency: number;
  maxFrequency: number;
  canReset: BooleanLike;
  listening: BooleanLike;
  broadcasting: BooleanLike;
  loudspeaker: BooleanLike;
  has_loudspeaker: BooleanLike;
  ichannels: { [key: string]: number };
  schannels: { [key: string]: BooleanLike };
};

export const Radio = (props) => {
  const { act, data } = useBackend<RadioData>();
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
    ichannels,
    schannels,
  } = data;
  const tunedChannel = RADIO_CHANNELS.find((channel) => channel.freq === frequency);
  let matchedChannel = tunedChannel && tunedChannel.name ? true : false;
  let colorMap = [];
  RADIO_CHANNELS.forEach((radioChannel) => {
    colorMap[radioChannel.name] = radioChannel.color;
  });
  const secureChannels = map(schannels, (value, key) => ({
    name: key,
    status: !!value,
  }));
  const internalChannels = map(ichannels, (value, key) => ({
    name: key,
    freq: value,
  }));
  return (
    <Window width={375} height={130 + secureChannels.length * 21.2 + internalChannels.length * 11}>
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
                    animated
                    unit="kHz"
                    step={0.2}
                    stepPixelSize={10}
                    minValue={minFrequency / 10}
                    maxValue={maxFrequency / 10}
                    value={frequency / 10}
                    format={(value) => toFixed(value, 1)}
                    onChange={(value) =>
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
              {matchedChannel && tunedChannel && (
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
                {secureChannels.map((channel) => (
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
            {internalChannels.length !== 0 && (
              <LabeledList.Item label="Standard Channel">
                {internalChannels.map((channel) => (
                  <Button
                    key={'i_' + channel.name}
                    icon="arrow-right"
                    content={channel.name}
                    selected={matchedChannel && tunedChannel && tunedChannel.name === channel.name}
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
