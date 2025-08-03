import { Box, Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const addcommas = (x) => {
  return x.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');
};

export const TEG = (props) => {
  const { act, data } = useBackend();
  if (data.error) {
    return (
      <Window width={500} height={400}>
        <Window.Content>
          <Section title="Error">
            {data.error}
            <Button icon="circle" content="Recheck" onClick={() => act('check')} />
          </Section>
        </Window.Content>
      </Window>
    );
  }
  return (
    <Window width={500} height={400}>
      <Window.Content>
        <Section title={'Cold Loop (' + data.cold_dir + ')'}>
          <LabeledList>
            <LabeledList.Item label="Cold Inlet">
              {addcommas(data.cold_inlet_temp)} K, {addcommas(data.cold_inlet_pressure)} kPa
            </LabeledList.Item>
            <LabeledList.Item label="Cold Outlet">
              {addcommas(data.cold_outlet_temp)} K, {addcommas(data.cold_outlet_pressure)} kPa
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title={'Hot Loop (' + data.hot_dir + ')'}>
          <LabeledList>
            <LabeledList.Item label="Hot Inlet">
              {addcommas(data.hot_inlet_temp)} K, {addcommas(data.hot_inlet_pressure)} kPa
            </LabeledList.Item>
            <LabeledList.Item label="Hot Outlet">
              {addcommas(data.hot_outlet_temp)} K, {addcommas(data.hot_outlet_pressure)} kPa
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Power Output">
          {addcommas(data.output_power)} W
          {!!data.warning_switched && (
            <Box color="red">Warning: Cold inlet temperature exceeds hot inlet temperature.</Box>
          )}
          {!!data.warning_cold_pressure && (
            <Box color="red">Warning: Cold circulator inlet pressure is under 1,000 kPa.</Box>
          )}
          {!!data.warning_hot_pressure && (
            <Box color="red">Warning: Hot circulator inlet pressure is under 1,000 kPa.</Box>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
