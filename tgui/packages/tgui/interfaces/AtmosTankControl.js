import { useBackend } from '../backend';
import { Button, Section, NumberInput, LabeledList, ProgressBar } from '../components';
import { toFixed } from 'common/math';
import { getGasColor, getGasLabel } from '../constants';
import { Window } from '../layouts';

export const AtmosTankControl = (props, context) => {
  const { act, data } = useBackend(context);

  let sensors_list = data.sensors || {};

  return (
    <Window width={400} height={400}>
      <Window.Content scrollable>
        {Object.keys(sensors_list).map((s) => (
          <Section key={s} title={s}>
            <LabeledList>
              {Object.keys(sensors_list[s]).indexOf('pressure') > -1 ? (
                <LabeledList.Item label="Pressure">{sensors_list[s]['pressure']} kpa</LabeledList.Item>
              ) : (
                ''
              )}
              {Object.keys(sensors_list[s]).indexOf('temperature') > -1 ? (
                <LabeledList.Item label="Temperature">{sensors_list[s]['temperature']} K</LabeledList.Item>
              ) : (
                ''
              )}

              {['o2', 'n2', 'plasma', 'co2', 'n2o'].map((g) =>
                Object.keys(sensors_list[s]).indexOf(g) > -1 ? (
                  <LabeledList.Item key={getGasLabel(g)} label={getGasLabel(g)}>
                    <ProgressBar color={getGasColor(g)} value={sensors_list[s][g]} minValue={0} maxValue={100}>
                      {toFixed(sensors_list[s][g], 2) + '%'}
                    </ProgressBar>
                  </LabeledList.Item>
                ) : (
                  ''
                )
              )}
            </LabeledList>
          </Section>
        ))}
        {data.inlet && Object.keys(data.inlet).length > 0 ? (
          <Section title="Inlet Control">
            <LabeledList>
              <LabeledList.Item label="Power">
                <Button
                  icon={data.inlet.on ? 'power-off' : 'power-off'}
                  content={data.inlet.on ? 'On' : 'Off'}
                  color={data.inlet.on ? null : 'red'}
                  selected={data.inlet.on}
                  onClick={() => act('toggle_active', { dev: 'inlet' })}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Rate">
                <NumberInput
                  animated
                  unit={'L/s'}
                  width={6.1}
                  lineHeight={1.5}
                  step={1}
                  minValue={0}
                  maxValue={50}
                  value={data.inlet.rate}
                  onDrag={(e, value) =>
                    act('set_pressure', {
                      dev: 'inlet',
                      val: value,
                    })
                  }
                />
              </LabeledList.Item>
            </LabeledList>
          </Section>
        ) : (
          ''
        )}
        {data.outlet && Object.keys(data.outlet).length > 0 ? (
          <Section title="Outlet Control">
            <LabeledList>
              <LabeledList.Item label="Power">
                <Button
                  icon={data.outlet.on ? 'power-off' : 'power-off'}
                  content={data.outlet.on ? 'On' : 'Off'}
                  color={data.outlet.on ? null : 'red'}
                  selected={data.outlet.on}
                  onClick={() => act('toggle_active', { dev: 'outlet' })}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Rate">
                <NumberInput
                  animated
                  unit={'kPa'}
                  width={6.1}
                  lineHeight={1.5}
                  step={10}
                  minValue={0}
                  maxValue={5066}
                  value={data.outlet.rate}
                  onDrag={(e, value) =>
                    act('set_pressure', {
                      dev: 'outlet',
                      val: value,
                    })
                  }
                />
              </LabeledList.Item>
            </LabeledList>
          </Section>
        ) : (
          ''
        )}
      </Window.Content>
    </Window>
  );
};
