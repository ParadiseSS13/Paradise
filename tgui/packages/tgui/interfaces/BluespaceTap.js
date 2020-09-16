import { useBackend } from '../backend';
import { Button, Collapsible, Flex, LabeledList, Section, Tabs } from '../components';
import { Window } from '../layouts';
import { formatPower } from '../format';


export const BluespaceTap = (props, context) => {
  const { act, data } = useBackend(context);
  const product = data.product || [];
  const level_color = (
    data.desired_level > data.safe_levels && 'bad'
    || null
  );
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Collapsible
          title="Input Management">
          <Section title="Input">
            <LabeledList>
              <LabeledList.Item label="Input Level">
                {data.input_level}
              </LabeledList.Item>
              <LabeledList.Item label="Desired Level">
                <Button
                  icon="minus"
                  disabled={data.desired_level === 0}
                  color={level_color}
                  onClick={() => act("decrease")} />
                <Button
                  onClick={() => act("set")}>
                  {data.desired_level}
                </Button>
                <Button
                  icon="plus"
                  disabled={data.desired_level === data.max_level}
                  onClick={() => act("increase")} />
              </LabeledList.Item>
              <LabeledList.Item label="Current Power Use">
                {formatPower(data.power_use)}
              </LabeledList.Item>
              <LabeledList.Item label="Surplus Power">
                {formatPower(data.available_power)}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Collapsible>
        <Section title="Mining Points">
          <LabeledList>
            <LabeledList.Item label="Available Points">
              {data.points}
            </LabeledList.Item>
            <LabeledList.Item label="Total Points">
              {data.total_points}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Available Targets">
          <LabeledList>
            {product.map(singleProduct => (
              <LabeledList.Item key={singleProduct.key}
                label={singleProduct.name}>
                <Button
                  disabled={singleProduct.price >= data.points}
                  onClick={() => act('vend', { target: singleProduct.key })}
                  content={singleProduct.price}
                />
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
