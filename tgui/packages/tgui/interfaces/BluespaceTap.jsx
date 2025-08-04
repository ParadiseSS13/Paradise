import {
  Blink,
  Box,
  Button,
  Collapsible,
  Dimmer,
  Icon,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';
import { formatPower } from 'tgui-core/format';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const Incursion = (props) => {
  const { data } = useBackend();
  const { portaling } = data;
  if (portaling) {
    return (
      <Dimmer fontsize="256px" backgroundColor="rgba(35,0,0,0.85)">
        <Blink
          fontsize="256px"
          interval={Math.random() > 0.25 ? 750 + 400 * Math.random() : 290 + 150 * Math.random()}
          time={60 + 150 * Math.random()}
        >
          <Stack mb="30px" fontsize="256px">
            <Stack.Item bold color="red" fontsize="256px" textAlign="center">
              <Icon name="skull" size={14} mb="64px" />
              <br />
              E$#OR:& U#KN!WN IN%ERF#R_NCE
            </Stack.Item>
          </Stack>
        </Blink>
      </Dimmer>
    );
  }
};

export const BluespaceTap = (props) => {
  const { act, data } = useBackend();
  const product = data.product || [];
  const {
    desiredMiningPower,
    miningPower,
    points,
    totalPoints,
    powerUse,
    availablePower,
    emagged,
    dirty,
    autoShutown,
    stabilizers,
    stabilizerPower,
    stabilizerPriority,
  } = data;
  const barColor = (desiredMiningPower > miningPower && 'bad') || 'good';
  return (
    <Window width={650} height={450}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Incursion />
          <Alerts />
          <Collapsible title="Input Management">
            <Section fill title="Input">
              <Button
                icon={!!autoShutown && !emagged ? 'toggle-on' : 'toggle-off'}
                content="Auto shutdown"
                color={!!autoShutown && !emagged ? 'green' : 'red'}
                disabled={!!emagged}
                tooltip="Turn auto shutdown on or off"
                tooltipPosition="top"
                onClick={() => act('auto_shutdown')}
              />
              <Button
                icon={!!stabilizers && !emagged ? 'toggle-on' : 'toggle-off'}
                content="Stabilizers"
                color={!!stabilizers && !emagged ? 'green' : 'red'}
                disabled={!!emagged}
                tooltip="Turn stabilizers on or off"
                tooltipPosition="top"
                onClick={() => act('stabilizers')}
              />
              <Button
                icon={!!stabilizerPriority && !emagged ? 'toggle-on' : 'toggle-off'}
                content="Stabilizer priority"
                color={!!stabilizerPriority && !emagged ? 'green' : 'red'}
                disabled={!!emagged}
                tooltip="On: Mining power will not exceed what can be stabilized"
                tooltipPosition="top"
                onClick={() => act('stabilizer_priority')}
              />
              <LabeledList>
                <LabeledList.Item label="Desired Mining Power">{formatPower(desiredMiningPower)}</LabeledList.Item>
                <LabeledList.Item verticalAlign="top" label="Set Desired Mining Power">
                  <Stack width="100%">
                    <Stack.Item>
                      <Button
                        icon="step-backward"
                        disabled={desiredMiningPower === 0 || emagged}
                        tooltip="Set to 0"
                        tooltipPosition="bottom"
                        onClick={() => act('set', { set_power: 0 })}
                      />
                      <Button
                        icon="fast-backward"
                        tooltip="Decrease by 10 MW"
                        tooltipPosition="bottom"
                        disabled={desiredMiningPower === 0 || emagged}
                        onClick={() => act('set', { set_power: desiredMiningPower - 10000000 })}
                      />
                      <Button
                        icon="backward"
                        disabled={desiredMiningPower === 0 || emagged}
                        tooltip="Decrease by 1 MW"
                        tooltipPosition="bottom"
                        onClick={() => act('set', { set_power: desiredMiningPower - 1000000 })}
                      />
                    </Stack.Item>
                    <Stack.Item mx={1}>
                      <NumberInput
                        disabled={emagged}
                        minValue={0}
                        value={desiredMiningPower}
                        maxValue={Infinity}
                        step={1}
                        onChange={(value) =>
                          act('set', {
                            set_power: value,
                          })
                        }
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="forward"
                        disabled={emagged}
                        tooltip="Increase by one MW"
                        tooltipPosition="bottom"
                        onClick={() => act('set', { set_power: desiredMiningPower + 1000000 })}
                      />
                      <Button
                        icon="fast-forward"
                        disabled={emagged}
                        tooltip="Increase by 10MW"
                        tooltipPosition="bottom"
                        onClick={() => act('set', { set_power: desiredMiningPower + 10000000 })}
                      />
                    </Stack.Item>
                  </Stack>
                </LabeledList.Item>
                <LabeledList.Item label="Total Power Use">{formatPower(powerUse)}</LabeledList.Item>
                <LabeledList.Item label="Mining Power Use">{formatPower(miningPower)}</LabeledList.Item>
                <LabeledList.Item label="Stabilizer Power Use">{formatPower(stabilizerPower)}</LabeledList.Item>
                <LabeledList.Item label="Surplus Power">{formatPower(availablePower)}</LabeledList.Item>
              </LabeledList>
            </Section>
          </Collapsible>
          <Section fill title="Output">
            {dirty ? (
              <Dimmer backgroundColor="rgba(63, 39, 18, 0.85)">
                <Stack mb="30px" fontsize="256px">
                  <Stack.Item bold color="brown" fontsize="256px" textAlign="center">
                    Blockage Detected
                    <br />
                    Cleanup Required
                  </Stack.Item>
                </Stack>
              </Dimmer>
            ) : (
              ''
            )}
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

export const Alerts = (props) => {
  const { act, data } = useBackend();
  const product = data.product || [];
  const { miningPower, stabilizerPower, emagged, safeLevels, autoShutown, stabilizers, overhead } = data;
  return (
    <>
      {!autoShutown && !emagged && <NoticeBox danger={1}>Auto shutdown disabled</NoticeBox>}
      {emagged ? (
        <NoticeBox danger={1}>All safeties disabled</NoticeBox>
      ) : miningPower <= 15000000 ? (
        ''
      ) : !stabilizers ? (
        <NoticeBox danger={1}>Stabilizers disabled, Instability likely</NoticeBox>
      ) : miningPower > stabilizerPower + 15000000 ? (
        <NoticeBox danger={1}>Stabilizers overwhelmed, Instability likely</NoticeBox>
      ) : (
        <NoticeBox>High Power, engaging stabilizers</NoticeBox>
      )}
    </>
  );
};
