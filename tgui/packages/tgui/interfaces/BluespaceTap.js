import { useBackend } from '../backend';
import { Button, Collapsible, Stack, LabeledList, NoticeBox, Section, Slider, Box } from '../components';
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
  const barColor = (desiredLevel > inputLevel && 'bad') || 'good';
  return (
    <Window width={650} height={450}>
      <Window.Content scrollable>
        <Stack fill vertical>
          {!!emagged && <NoticeBox danger={1}>Safety Protocols disabled</NoticeBox>}
          {!!(inputLevel > safeLevels) && <NoticeBox danger={1}>High Power, Instability likely</NoticeBox>}
          <Collapsible title="Input Management">
            <Section fill title="Input">
              <LabeledList>
                <LabeledList.Item label="Input Level">{inputLevel}</LabeledList.Item>
                <LabeledList.Item label="Desired Level">
                  <Stack inline width="100%">
                    <Stack.Item>
                      <Button
                        icon="fast-backward"
                        disabled={desiredLevel === 0}
                        tooltip="Set to 0"
                        onClick={() => act('set', { set_level: 0 })}
                      />
                      <Button
                        icon="step-backward"
                        tooltip="Decrease to actual input level"
                        disabled={desiredLevel === 0}
                        onClick={() => act('set', { set_level: inputLevel })}
                      />
                      <Button
                        icon="backward"
                        disabled={desiredLevel === 0}
                        tooltip="Decrease one step"
                        onClick={() => act('decrease')}
                      />
                    </Stack.Item>
                    <Stack.Item grow={1} mx={1}>
                      <Slider
                        value={desiredLevel}
                        fillValue={inputLevel}
                        minValue={0}
                        color={barColor}
                        maxValue={maxLevel}
                        stepPixelSize={20}
                        step={1}
                        onChange={(e, value) =>
                          act('set', {
                            set_level: value,
                          })
                        }
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="forward"
                        disabled={desiredLevel === maxLevel}
                        tooltip="Increase one step"
                        tooltipPosition="left"
                        onClick={() => act('increase')}
                      />
                      <Button
                        icon="fast-forward"
                        disabled={desiredLevel === maxLevel}
                        tooltip="Set to max"
                        tooltipPosition="left"
                        onClick={() => act('set', { set_level: maxLevel })}
                      />
                    </Stack.Item>
                  </Stack>
                </LabeledList.Item>
                <LabeledList.Item label="Current Power Use">{formatPower(powerUse)}</LabeledList.Item>
                <LabeledList.Item label="Power for next level">{formatPower(nextLevelPower)}</LabeledList.Item>
                <LabeledList.Item label="Surplus Power">{formatPower(availablePower)}</LabeledList.Item>
              </LabeledList>
            </Section>
          </Collapsible>
          <Section fill title="Output">
            <Stack>
              <Stack.Item>
                <Box>
                  <LabeledList>
                    <LabeledList.Item label="Available Points">{points}</LabeledList.Item>
                    <LabeledList.Item label="Total Points">{totalPoints}</LabeledList.Item>
                  </LabeledList>
                </Box>
              </Stack.Item>
              <Stack.Item align="end">
                <Box>
                  <LabeledList>
                    {product.map((singleProduct) => (
                      <LabeledList.Item key={singleProduct.key} label={singleProduct.name}>
                        <Button
                          disabled={singleProduct.price >= points}
                          onClick={() => act('vend', { target: singleProduct.key })}
                          content={singleProduct.price}
                        />
                      </LabeledList.Item>
                    ))}
                  </LabeledList>
                </Box>
              </Stack.Item>
            </Stack>
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};
