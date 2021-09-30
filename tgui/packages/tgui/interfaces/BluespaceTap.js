import { useBackend } from '../backend';
import { Button, Collapsible, Flex, LabeledList, NoticeBox, Section, Slider, Box } from '../components';
import { Window } from '../layouts';
import { formatPower } from '../format';


export const BluespaceTap = (props, context) => {
  const { act, data } = useBackend(context);
  const product = data.product || [];
  const {
    desiredLevel,
    inputLevel,
    points,
    totalPoints,
    powerUse,
    availablePower,
    maxLevel,
    emagged,
    safeLevels,
    nextLevelPower,
  } = data;
  const barColor = (desiredLevel > inputLevel && 'bad'
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
        {!!(inputLevel > safeLevels) && (
          <NoticeBox danger={1}>
            High Power, Instability likely
          </NoticeBox>
        )}
        <Collapsible
          title="Input Management">
          <Section title="Input">
            <LabeledList>
              <LabeledList.Item label="Input Level">
                {inputLevel}
              </LabeledList.Item>
              <LabeledList.Item label="Desired Level">
                <Flex inline width="100%">
                  <Flex.Item>
                    <Button
                      icon="fast-backward"
                      disabled={desiredLevel === 0}
                      tooltip="Set to 0"
                      onClick={() => act('set', { set_level: 0 })} />
                    <Button
                      icon="step-backward"
                      tooltip="Decrease to actual input level"
                      disabled={desiredLevel === 0}
                      onClick={() => act('set', { set_level: inputLevel })} />
                    <Button
                      icon="backward"
                      disabled={desiredLevel === 0}
                      tooltip="Decrease one step"
                      onClick={() => act('decrease')} />
                  </Flex.Item>
                  <Flex.Item grow={1} mx={1}>
                    <Slider
                      value={desiredLevel}
                      fillValue={inputLevel}
                      minValue={0}
                      color={barColor}
                      maxValue={maxLevel}
                      stepPixelSize={20}
                      step={1}
                      onChange={(e, value) => act('set', {
                        set_level: value,
                      })} />
                  </Flex.Item>
                  <Flex.Item>
                    <Button
                      icon="forward"
                      disabled={desiredLevel === maxLevel}
                      tooltip="Increase one step"
                      tooltipPosition="left"
                      onClick={() => act("increase")} />
                    <Button
                      icon="fast-forward"
                      disabled={desiredLevel === maxLevel}
                      tooltip="Set to max"
                      tooltipPosition="left"
                      onClick={() => act("set", { set_level: maxLevel })} />
                  </Flex.Item>
                </Flex>
              </LabeledList.Item>
              <LabeledList.Item label="Current Power Use">
                {formatPower(powerUse)}
              </LabeledList.Item>
              <LabeledList.Item label="Power for next level">
                {formatPower(nextLevelPower)}
              </LabeledList.Item>
              <LabeledList.Item label="Surplus Power">
                {formatPower(availablePower)}
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
                    {totalPoints}
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
