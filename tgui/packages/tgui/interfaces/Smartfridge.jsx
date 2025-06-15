import { Button, Icon, NoticeBox, NumberInput, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const Smartfridge = (props) => {
  const { act, data } = useBackend();
  const {
    secure, // secure fridge notice
    can_dry, // dry section
    drying, // drying rack on/off.
    contents,
  } = data;
  return (
    <Window width={500} height={500}>
      <Window.Content>
        <Stack fill vertical>
          {!!secure && <NoticeBox>Secure Access: Please have your identification ready.</NoticeBox>}
          <Section
            fill
            scrollable
            title={can_dry ? 'Drying rack' : 'Contents'}
            buttons={
              !!can_dry && (
                <Button
                  width={4}
                  icon={drying ? 'power-off' : 'times'}
                  content={drying ? 'On' : 'Off'}
                  selected={drying}
                  onClick={() => act('drying')}
                />
              )
            }
          >
            {!contents && (
              <Stack fill>
                <Stack.Item bold grow textAlign="center" align="center" color="average">
                  <Icon.Stack>
                    <Icon name="cookie-bite" size={5} color="brown" />
                    <Icon name="slash" size={5} color="red" />
                  </Icon.Stack>
                  <br />
                  No products loaded.
                </Stack.Item>
              </Stack>
            )}
            {!!contents &&
              contents
                .slice()
                .sort((a, b) => a.display_name.localeCompare(b.display_name))
                .map((item) => {
                  return (
                    <Stack key={item}>
                      <Stack.Item width="55%">{item.display_name}</Stack.Item>
                      <Stack.Item width="25%">({item.quantity} in stock)</Stack.Item>
                      <Stack.Item width={13}>
                        <Button
                          width={3}
                          icon="arrow-down"
                          tooltip="Dispense one."
                          content="1"
                          onClick={() => act('vend', { index: item.vend, amount: 1 })}
                        />
                        <NumberInput
                          width="40px"
                          minValue={0}
                          value={0}
                          maxValue={item.quantity}
                          step={1}
                          stepPixelSize={3}
                          onChange={(value) => act('vend', { index: item.vend, amount: value })}
                        />
                        <Button
                          width={4}
                          icon="arrow-down"
                          content="All"
                          tooltip="Dispense all."
                          tooltipPosition="bottom-start"
                          onClick={() =>
                            act('vend', {
                              index: item.vend,
                              amount: item.quantity,
                            })
                          }
                        />
                      </Stack.Item>
                    </Stack>
                  );
                })}
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};
