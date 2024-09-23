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
    nextLevelPower,
    autoShutown,
    stabilizers,
    stabilizerPower,
  } = data;
  const barColor = (desiredLevel > inputLevel && 'bad') || 'good';
  return (
    <Window width={650} height={450}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Alerts />
          <Collapsible title="Input Management">
            <Section fill title="Input">
              <Button
                icon={!!autoShutown && !emagged ? 'toggle-on' : 'toggle-off'}
                content="Auto shutdown"
                color={!!autoShutown && !emagged ? 'green' : 'red'}
                disabled={!!emagged}
                tooltip="Turn auto shutdown on or off"
                onClick={() => act('auto_shutdown')}
              />
              <Button
                icon={!!stabilizers && !emagged ? 'toggle-on' : 'toggle-off'}
                content="Stabilizers"
                color={!!stabilizers && !emagged ? 'green' : 'red'}
                disabled={!!emagged}
                tooltip="Turn stabilizers on or off"
                onClick={() => act('stabilizers')}
              />
              <LabeledList>
                <LabeledList.Item label="Input Level">{inputLevel}</LabeledList.Item>
                <LabeledList.Item label="Desired Level">
                  <Stack inline width="100%">
                    <Stack.Item>
                      <Button
                        icon="fast-backward"
                        disabled={desiredLevel === 0 || emagged}
                        tooltip="Set to 0"
                        onClick={() => act('set', { set_level: 0 })}
                      />
                      <Button
                        icon="step-backward"
                        tooltip="Decrease to actual input level"
                        disabled={desiredLevel === 0 || emagged}
                        onClick={() => act('set', { set_level: inputLevel })}
                      />
                      <Button
                        icon="backward"
                        disabled={desiredLevel === 0 || emagged}
                        tooltip="Decrease one step"
                        onClick={() => act('decrease')}
                      />
                    </Stack.Item>
                    <Stack.Item grow={1} mx={1}>
                      <Slider
                        disabled={emagged}
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
                        disabled={desiredLevel === maxLevel || emagged}
                        tooltip="Increase one step"
                        tooltipPosition="left"
                        onClick={() => act('increase')}
                      />
                      <Button
                        icon="fast-forward"
                        disabled={desiredLevel === maxLevel || emagged}
                        tooltip="Set to max"
                        tooltipPosition="left"
                        onClick={() => act('set', { set_level: maxLevel })}
                      />
                    </Stack.Item>
                  </Stack>
                </LabeledList.Item>
                <LabeledList.Item label="Total Power Use">{formatPower(powerUse)}</LabeledList.Item>
                <LabeledList.Item label="Mining Power Use">{formatPower(powerUse - stabilizerPower)}</LabeledList.Item>
                <LabeledList.Item label="Stabilizer Power Use">{formatPower(stabilizerPower)}</LabeledList.Item>
                <LabeledList.Item label="Mining Power for next level">{formatPower(nextLevelPower)}</LabeledList.Item>
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

export const Alerts = (props, context) => {
  const { act, data } = useBackend(context);
  const product = data.product || [];
  const { inputLevel, emagged, safeLevels, autoShutown, stabilizers, overhead } = data;
  return (
    <>
      {!autoShutown && !emagged && <NoticeBox danger={1}>Auto shutdown disabled</NoticeBox>}
      {emagged ? (
        <NoticeBox danger={1}>All safeties disabled</NoticeBox>
      ) : inputLevel <= safeLevels ? (
        ''
      ) : !stabilizers ? (
        <NoticeBox danger={1}>Stabilizers disabled, Instability likely</NoticeBox>
      ) : inputLevel - overhead > safeLevels ? (
        <NoticeBox danger={1}>Stabilizers overwhelmed, Instability likely</NoticeBox>
      ) : (
        <NoticeBox>High Power, engaging stabilizers</NoticeBox>
      )}
    </>
  );
};
