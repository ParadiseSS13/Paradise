import { useBackend } from '../backend';
import { Box, Section, Button, Flex, LabeledList } from '../components';
import { Window } from '../layouts';

export const SecureStorage = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    emagged,
    locked,
    l_set,
    l_setshort,
    current_code,
  } = data;

  const SafeButton = ({ buttonValue, color }) => {
    if (!color) {
      color = 'default';
    }

    return (
      <Button disabled={emagged || l_setshort} type="button" color={color} onClick={() => act('setnumber', { buttonValue })}>
        {buttonValue}
      </Button>
    );
  };

  return (
    <Window>
      <Flex spacing="1">
        <Flex.Item
          width={16}
          shrink={0}
          textAlign="center">
          <Section title="Code Panel">
            <Flex.Item>
              <SafeButton buttonValue={"1"} />
              <SafeButton buttonValue={"2"} />
              <SafeButton buttonValue={"3"} />
            </Flex.Item>
            <Flex.Item>
              <SafeButton buttonValue={"4"} />
              <SafeButton buttonValue={"5"} />
              <SafeButton buttonValue={"6"} />
            </Flex.Item>
            <Flex.Item>
              <SafeButton buttonValue={"7"} />
              <SafeButton buttonValue={"8"} />
              <SafeButton buttonValue={"9"} />
            </Flex.Item>
            <Flex.Item>
              <SafeButton buttonValue={"R"} color={"red"} />
              <SafeButton buttonValue={"0"} />
              <SafeButton buttonValue={"E"} color={"green"} />
            </Flex.Item>
          </Section>
        </Flex.Item>
        <Section title="Current Status">
          {emagged || l_setshort ? (
            <LabeledList>
              <LabeledList.Item label="Lock Status">
                <Box color="red">
                  {emagged ? "LOCKING SYSTEM ERROR - 1701" : "ALERT: MEMORY SYSTEM ERROR - 6040 201"}
                </Box>
              </LabeledList.Item>
              {emagged ? (
                <LabeledList.Item label="Input Code">
                  <Box color="red">
                    NEW INPUT, ASSHOLE
                  </Box>
                </LabeledList.Item>
              ) : (
                ""
              )}
            </LabeledList>
          ) : (
            <LabeledList>
              <LabeledList.Item label="Secure Code">
                <Box color={l_set ? "red": "green"}>
                  {l_set ? "*****" : "NOT SET. ENTER NEW."}
                </Box>
              </LabeledList.Item>
              <LabeledList.Item label="Lock Status">
                <Box color={locked ? "red": "green"}>
                  {locked ? "Locked" : "Unlocked"}
                </Box>
              </LabeledList.Item>
              <LabeledList.Item label="Input Code">
                <Box>
                  {current_code ? current_code : "Waiting for input"}
                </Box>
              </LabeledList.Item>
              <Button
                top=".35em"
                left=".5em"
                disabled={locked}
                color="red"
                content="Lock"
                icon="lock"
                onClick={() => act('close')} />
            </LabeledList>
          )}
        </Section>
      </Flex>
    </Window>
  );
};
