import { useBackend } from '../backend';
import { Section, LabeledList } from '../components';
import { Window } from '../layouts';

export const Transformer = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    wattage_setting,
    last_output,
  } = data;

  return (
    <Window>
      <Window.Content>
        <Section label="Transformer">
          <LabeledList>
            <LabeledList.Item label="Wattage Setting">{wattage_setting}</LabeledList.Item>
            <LabeledList.Item label="Last Ouput">{last_output}</LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
