import { useBackend } from '../backend';
import { Button, Collapsible, Flex, LabeledList, NoticeBox, Section, Slider, Box } from '../components';
import { Window } from '../layouts';
import { formatPower } from '../format';


export const BluespaceTap = (props, context) => {
  const { act, data } = useBackend(context);
  const product = data.product || [];
  const {
    desired_level,
    input_level,
    points,
    total_points,
    power_use,
    available_power,
    max_level,
    emagged,
    safe_levels,
    next_level_power,
  } = data;
  const barColor = (desired_level > input_level && 'bad'
    || 'good'
  );
  return (
    <Window resizable>
      <Window.Content scrollable>
        {!!emagged && (
          <NoticeBox danger={1}>
            Safety Protocols disabled
          </NoticeBox>
        )}
        {!!(input_level > safe_levels) && (
          <NoticeBox danger={1}>
            High Power, Instability likely
          </NoticeBox>
        )}
        <Collapsible
          title="Input Management">
          <Section title="Input">
            <LabeledList>
              <LabeledList.Item label="Input Level">
                {input_level}
              </LabeledList.Item>
              <LabeledList.Item label="Desired Level">
                <Flex inline width="100%">
                  <Flex.Item>
                    <Button
                      icon="fast-backward"
                      disabled={desired_level === 0}
                      onClick={() => act('set', { set_level: 0 })} />
                    <Button
                      icon="minus"
                      disabled={desired_level === 0}
                      onClick={() => act('decrease')} />
                  </Flex.Item>
                  <Flex.Item grow={1} mx={1}>
                    <Slider
                      value={desired_level}
                      fillValue={input_level}
                      minValue={0}
                      color={barColor}
                      maxValue={max_level}
                      stepPixelSize={20}
                      step={1}
                      onChange={(e, value) => act('set', {
                        set_level: value,
                      })} />
                  </Flex.Item>
                  <Flex.Item>
                    <Button
                      icon="plus"
                      disabled={desired_level === max_level}
                      onClick={() => act("increase")} />
                  </Flex.Item>
                </Flex>
              </LabeledList.Item>
              <LabeledList.Item label="Current Power Use">
                {formatPower(power_use)}
              </LabeledList.Item>
              <LabeledList.Item label="Power for next level">
                {formatPower(next_level_power)}
              </LabeledList.Item>
              <LabeledList.Item label="Surplus Power">
                {formatPower(available_power)}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Collapsible>
        <Section title="Output">
        <Flex>
          <Flex.Item>
        <Box>
          <LabeledList>
            <LabeledList.Item label="Available Points">
              {points}
            </LabeledList.Item>
            <LabeledList.Item label="Total Points">
              {total_points}
            </LabeledList.Item>
          </LabeledList>
        </Box>
        </Flex.Item>
        <Flex.Item align="end">
        <Box>
          <LabeledList>
            {product.map(singleProduct => (
              <LabeledList.Item key={singleProduct.key}
                label={singleProduct.name}>
                <Button
                  disabled={singleProduct.price >= points}
                  onClick={() => act('vend', { target: singleProduct.key })}
                  content={singleProduct.price}
                />
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Box>
        </Flex.Item>
        </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};
