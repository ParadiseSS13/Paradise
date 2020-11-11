import { useBackend } from '../backend';
import { Box, Section, Button, NumberInput, Flex, NoticeBox } from '../components';
import { Window } from '../layouts';

export const Smartfridge = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    secure, // secure fridge notice
    can_dry, // dry section
    drying, // drying rack on/off.
    contents,
  } = data;
  return (
    <Window>
      <Window.Content>
        {!!secure && (
          <Section title="Secure">
            <NoticeBox>
              Secure Access: Please have your identification ready.
            </NoticeBox>
          </Section>
        )}
        {!!can_dry && (
          <Section title="Drying rack">
            <Button
              icon={drying ? 'power-off' : 'times'}
              content={drying ? 'On' : 'Off'}
              selected={drying}
              onClick={() => act('drying')} />
          </Section>
        )}
        <Section title="Contents">
          {!contents && (
            <Box color="average"> No products loaded. </Box>
          )}
          {!!contents && contents.map(item => {
            return (
              <Flex direction="row" key={item}>
                <Flex.Item width="45%">
                  {item.display_name}
                </Flex.Item>
                <Flex.Item width="25%">
                  ({item.quantity} in stock)
                </Flex.Item>
                <Flex.Item width="30%">
                  <Button
                    icon="arrow-down"
                    tooltip="Dispense one."
                    content="1"
                    onClick={() => act('vend',
                      { index: item.vend, amount: 1 })} />
                  <NumberInput
                    width="40px"
                    minValue={0}
                    value={0}
                    maxValue={item.quantity}
                    step={1}
                    stepPixelSize={3}
                    onChange={(e, value) => act('vend',
                      { index: item.vend, amount: value })} />
                  <Button
                    icon="arrow-down"
                    content="All"
                    tooltip="Dispense all. "
                    onClick={() => act('vend',
                      { index: item.vend, amount: item.quantity })} />
                </Flex.Item>
              </Flex>
            );
          })}
        </Section>
      </Window.Content>
    </Window>
  );
};
