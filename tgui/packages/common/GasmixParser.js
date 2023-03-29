import { useBackend } from '../tgui/backend';
import { LabeledList, Box } from '../tgui/components';

export const GasmixParser = (props, context) => {
  const { act, data } = useBackend(context);
  const { gasmixes } = data;

  return !gasmixes[0].total_moles ? (
    <Box nowrap italic mb="10px">
      {'No Gas Detected!'}
    </Box>
  ) : (
    <LabeledList>
      <LabeledList.Item label={'Total Moles'}>
        {(gasmixes[0].total_moles ? gasmixes[0].total_moles : '-') + ' mol'}
      </LabeledList.Item>
      {gasmixes[0].oxygen ? (
        <LabeledList.Item label={'Oxygen'}>
          {gasmixes[0].oxygen.toFixed(2) + ' mol (' + (gasmixes[0].oxygen / gasmixes[0].total_moles).toFixed(2) * 100 + ' %)'}
        </LabeledList.Item>
      ) : ('')}
      {gasmixes[0].nitrogen ? (
        <LabeledList.Item label={'Nitrogen'}>
          {gasmixes[0].nitrogen.toFixed(2) + ' mol (' + (gasmixes[0].nitrogen / gasmixes[0].total_moles).toFixed(2) * 100 + ' %)'}
        </LabeledList.Item>
      ) : ('')}
      {gasmixes[0].carbon_dioxide ? (
        <LabeledList.Item label={'Carbon Dioxide'}>
          {gasmixes[0].carbon_dioxide.toFixed(2) + ' mol (' + (gasmixes[0].carbon_dioxide / gasmixes[0].total_moles).toFixed(2) * 100 + ' %)'}
        </LabeledList.Item>
      ) : ('')}
      {gasmixes[0].toxins ? (
        <LabeledList.Item label={'Plasma'}>
          {gasmixes[0].toxins.toFixed(2) + ' mol (' + (gasmixes[0].toxins / gasmixes[0].total_moles).toFixed(2) * 100 + ' %)'}
        </LabeledList.Item>
      ) : ('')}
      {gasmixes[0].sleeping_agent ? (
        <LabeledList.Item label={'Nitrous Oxide'}>
          {gasmixes[0].sleeping_agent.toFixed(2) + ' mol (' + (gasmixes[0].sleeping_agent / gasmixes[0].total_moles).toFixed(2) * 100 + ' %)'}
        </LabeledList.Item>
      ) : ('')}
      {gasmixes[0].agent_b ? (
        <LabeledList.Item label={'Agent B'}>
          {gasmixes[0].agent_b.toFixed(2) + ' mol (' + (gasmixes[0].agent_b / gasmixes[0].total_moles).toFixed(2) * 100 + ' %)'}
        </LabeledList.Item>
      ) : ('')}
      <LabeledList.Item label={'Temperature'}>
        {(gasmixes[0].total_moles ? (gasmixes[0].temperature - 273.15).toFixed(2) : '-') + ' °C (' + (gasmixes[0].total_moles ? gasmixes[0].temperature.toFixed(2) : '-') + ' K)'}
      </LabeledList.Item>
      <LabeledList.Item label={'Volume'}>
        {(gasmixes[0].total_moles ? gasmixes[0].volume : '-') + ' L'}
      </LabeledList.Item>
      <LabeledList.Item label={'Pressure'}>
        {(gasmixes[0].total_moles ? gasmixes[0].pressure.toFixed(2) : '-') + ' kPa'}
      </LabeledList.Item>
      <LabeledList.Item label={'Heat Capacity'}>
        {gasmixes[0].heat_capacity + ' / K'}
      </LabeledList.Item>
      <LabeledList.Item label={'Thermal Energy'}>
        {gasmixes[0].thermal_energy}
      </LabeledList.Item>
    </LabeledList>
  );
};
