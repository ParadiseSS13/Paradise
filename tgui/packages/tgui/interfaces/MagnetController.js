import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import {
  BlockQuote,
  Button,
  LabeledList,
  Section,
  Slider,
} from '../components';
import { Window } from '../layouts';
import { ComplexModal, modalOpen } from './common/ComplexModal';

const pathCodeMap = new Map([
  [
    'n',
    {
      icon: 'arrow-up',
      tooltip: 'Move North',
    },
  ],
  [
    'e',
    {
      icon: 'arrow-right',
      tooltip: 'Move East',
    },
  ],
  [
    's',
    {
      icon: 'arrow-down',
      tooltip: 'Move South',
    },
  ],
  [
    'w',
    {
      icon: 'arrow-left',
      tooltip: 'Move West',
    },
  ],
  [
    'c',
    {
      icon: 'crosshairs',
      tooltip: 'Move to Magnet',
    },
  ],
  [
    'r',
    {
      icon: 'dice',
      tooltip: 'Move Randomly',
    },
  ],
]);

export const MagnetController = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    autolink,
    code,
    frequency,
    linkedMagnets,
    magnetConfiguration,
    path,
    pathPosition,
    probing,
    powerState,
    speed,
  } = data;

  return (
    <Window resizable>
      <ComplexModal />
      <Window.Content scrollable>
        {!autolink && (
          <Section
            buttons={
              <Button
                content="Probe"
                icon={probing ? 'spinner' : 'sync'}
                iconSpin={!!probing}
                disabled={probing}
                onClick={() => act('probe_magnets')}
              />
            }
            title="Magnet Linking"
          >
            <LabeledList>
              <LabeledList.Item label="Frequency">
                {toFixed(frequency / 10, 1)}
              </LabeledList.Item>
              <LabeledList.Item label="Code">{code}</LabeledList.Item>
            </LabeledList>
          </Section>
        )}
        <Section
          buttons={
            <Button
              icon={powerState ? 'power-off' : 'times'}
              content={powerState ? 'On' : 'Off'}
              selected={powerState}
              onClick={() => act('toggle_power')}
            />
          }
          title="Controller Configuration"
        >
          <LabeledList>
            <LabeledList.Item label="Speed">
              <Slider
                value={speed.value}
                minValue={speed.min}
                maxValue={speed.max}
                onChange={(e, value) =>
                  act('set_speed', {
                    speed: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Path">
              {Array.from(pathCodeMap.entries()).map(
                ([code, { icon, tooltip }]) => (
                  <Button
                    key={code}
                    icon={icon}
                    tooltip={tooltip}
                    onClick={() => act(`path_add`, { code: code })}
                  />
                )
              )}
              <Button.Confirm
                icon="trash"
                confirmIcon="trash"
                confirmContent=""
                float="right"
                tooltip="Reset Path"
                tooltipPosition="left"
                onClick={() => act('path_clear')}
              />
              <Button
                icon="file-import"
                float="right"
                tooltip="Manually input path"
                tooltipPosition="left"
                onClick={() => modalOpen(context, 'path_custom_input')}
              />
              <BlockQuote>
                {path.map((code, i) => {
                  let { icon, tooltip } = pathCodeMap.get(code) || {
                    icon: 'question',
                  };
                  return (
                    <Button.Confirm
                      key={i}
                      // Do not know why + 2 works but it does.
                      selected={i + 2 === pathPosition}
                      icon={icon}
                      confirmIcon={icon}
                      confirmContent=""
                      tooltip={tooltip}
                      onClick={() =>
                        act('path_remove', {
                          index: i + 1,
                          code: code,
                        })
                      }
                    />
                  );
                })}
              </BlockQuote>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {linkedMagnets.map(
          ({ uid, powerState, electricityLevel, magneticField }, i) => {
            return (
              <Section
                key={uid}
                title={`Magnet #${i + 1} Configuration`}
                buttons={
                  <Button
                    icon={powerState ? 'power-off' : 'times'}
                    content={powerState ? 'On' : 'Off'}
                    selected={powerState}
                    onClick={() =>
                      act('toggle_magnet_power', {
                        id: uid,
                      })
                    }
                  />
                }
              >
                <LabeledList>
                  <LabeledList.Item label="Move Speed">
                    <Slider
                      value={electricityLevel}
                      minValue={magnetConfiguration.electricityLevel.min}
                      maxValue={magnetConfiguration.electricityLevel.max}
                      onChange={(e, value) =>
                        act('set_electricity_level', {
                          id: uid,
                          electricityLevel: value,
                        })
                      }
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Field Size">
                    <Slider
                      value={magneticField}
                      minValue={magnetConfiguration.magneticField.min}
                      maxValue={magnetConfiguration.magneticField.max}
                      onChange={(e, value) =>
                        act('set_magnetic_field', {
                          id: uid,
                          magneticField: value,
                        })
                      }
                    />
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            );
          }
        )}
      </Window.Content>
    </Window>
  );
};
