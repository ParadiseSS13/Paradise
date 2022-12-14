import { useBackend } from '../backend';
import { Button, Section, NumberInput, LabeledList, ProgressBar } from '../components';
import { toFixed } from 'common/math';
import { getGasColor, getGasLabel } from '../constants';
import { Window } from '../layouts';

export const AtmosTankControl = (props, context) => {
  const { act, data } = useBackend(context);

  let sensors_list = data.sensors || {};

  return (
    <Window resizable>
      <Window.Content scrollable>
        {Object.keys(sensors_list).map(s => (
          <Section key={s} title={s}>
            <LabeledList>
              <LabeledList.Item label="Pressure">
                {sensors_list[s]['pressure']} kpa
              </LabeledList.Item>
              <LabeledList.Item label="Temperature">
              {sensors_list[s]['temperature']}K
              </LabeledList.Item>
              {["o2", "n2", "plasma", "co2", "n2o"].map(g => (
                (Object.keys(sensors_list[s]).indexOf(g) > 0) ? (
                  <LabeledList.Item label={getGasLabel(g)}>
                    <ProgressBar
                      color={getGasColor(g)}
                      value={sensors_list[s][g]}
                      minValue={0}
                      maxValue={100}
                    >
                    {toFixed(sensors_list[s][g], 2) + '%'}
                    </ProgressBar>
                  </LabeledList.Item>
                ) : ("")
              ))}
            </LabeledList>
          </Section>
        ))}
      </Window.Content>
    </Window>
  );
};
