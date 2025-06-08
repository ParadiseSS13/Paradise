import { map } from 'common/collections';
import { toFixed } from 'common/math';

import { useBackend } from '../backend';
import { Section, Box, LabeledList, NumberInput, Button } from '../components';
import { RADIO_CHANNELS } from '../constants';
import { Window } from '../layouts';

type RadioData = {
  freqlock: boolean;
  frequency: number;
  minFrequency: number;
  maxFrequency: number;
  canReset: boolean;
  listening: boolean;
  broadcasting: boolean;
  hearRange: number;
  maxHearRange: number;
  hasFixedHearRange: boolean;
  schannels: Record<string, boolean>;
  ichannels: Record<string, number>;
};

export const Radio220 = (props, context) => {
  const { act, data } = useBackend<RadioData>(context);
  const {
    freqlock,
    frequency,
    minFrequency,
    maxFrequency,
    canReset,
    listening,
    broadcasting,
    hearRange,
    maxHearRange,
    hasFixedHearRange,
  } = data;
  const tunedChannel = RADIO_CHANNELS.find((channel) => channel.freq === data.frequency);
  const matchedChannel = tunedChannel && tunedChannel.name ? true : false;

  const channelColorMap = (() => {
    let colorMap: { [name: string]: string } = {};
    for (let i = 0; i < RADIO_CHANNELS.length; i++) {
      const channel = RADIO_CHANNELS[i];
      colorMap[channel['name']] = channel['color'];
    }
    return colorMap;
  })();

  const secure_channels = map((value, key) => ({
    name: key,
    status: !!value,
  }))(data.schannels);

  const internal_channels = map((value, key) => ({
    name: key,
    freq: value,
  }))(data.ichannels);

  const window_height = 130 + secure_channels.length * 21.2 + internal_channels.length * 11;

  return (
    <Window width={375} height={window_height}>
      <Window.Content scrollable>
        <Section fill>
          <LabeledList>
            <LabeledList.Item label="Частота">
              {(freqlock && (
                <Box inline color="light-gray">
                  {toFixed(data.frequency / 10, 1) + ' кГц'}
                </Box>
              )) || (
                <>
                  <NumberInput
                    animate
                    lineHeight={1.5}
                    unit="кГц"
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
            <LabeledList.Item label="Аудио">
              {hasFixedHearRange ? (
                ''
              ) : (
                <NumberInput
                  animate
                  unit="м"
                  width={6.35}
                  lineHeight={1.5}
                  step={1}
                  minValue={0}
                  maxValue={maxHearRange}
                  value={hearRange}
                  onDrag={(e, value) =>
                    act('range', {
                      set: value,
                    })
                  }
                />
              )}
              <Button
                textAlign="center"
                width="37px"
                icon={listening ? 'volume-up' : 'volume-mute'}
                selected={listening}
                color={listening ? '' : 'bad'}
                tooltip={listening ? 'Отключить прием' : 'Включить прием'}
                onClick={() => act('listen')}
              />
              <Button
                textAlign="center"
                width="37px"
                icon={broadcasting ? 'microphone' : 'microphone-slash'}
                selected={broadcasting}
                tooltip={broadcasting ? 'Отключить активацию голосом' : 'Включить активацию голосом'}
                onClick={() => act('broadcast')}
              />
            </LabeledList.Item>
            {secure_channels.length !== 0 && (
              <LabeledList.Item label="Доступные каналы">
                {secure_channels.map((channel) => (
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
                    <Box inline color={channelColorMap[channel.name]}>
                      {channel.name}
                    </Box>
                  </Box>
                ))}
              </LabeledList.Item>
            )}
            {internal_channels.length !== 0 && (
              <LabeledList.Item label="Стандартный канал">
                {internal_channels.map((channel) => (
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
