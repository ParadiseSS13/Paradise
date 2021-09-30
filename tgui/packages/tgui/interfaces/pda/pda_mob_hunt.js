import { useBackend } from "../../backend";
import { LabeledList, Box, Button, Section, Flex } from "../../components";

export const pda_mob_hunt = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    connected,
    wild_captures,
    no_collection,
    entry,
  } = data;

  return (
    <Box>
      <LabeledList>
        <LabeledList.Item label="Connection Status">
          {connected ? (
            <Box color="green">
              Connected
              <Button
                ml={2}
                content="Disconnect"
                icon="sign-out-alt"
                onClick={() => act('Disconnect')}
              />
            </Box>
          ) : (
            <Box color="red">
              Disconnected
              <Button
                ml={2}
                content="Connect"
                icon="sign-in-alt"
                onClick={() => act('Reconnect')}
              />
            </Box>
          )}
        </LabeledList.Item>
        <LabeledList.Item label="Total Wild Captures">
          {wild_captures}
        </LabeledList.Item>
      </LabeledList>
      <Section
        title="Collection"
        mt={2}
        buttons={
          // The double box wrapping is imporant here
          // Eslint argues with itself over indentation
          <Box>
            {!no_collection && (
              <Box>
                <Button
                  content="Previous"
                  icon="arrow-left"
                  onClick={() => act('Prev')} />
                <Button
                  content="Next"
                  icon="arrow-right"
                  onClick={() => act('Next')} />
              </Box>
            )}
          </Box>
        }>
        {no_collection ? (
          "Your collection is empty! Go capture some Nano-Mobs!"
        ) : (
          entry ? (
            <Flex>
              <Flex.Item>
                <img
                  src={entry.sprite}
                  style={{
                    width: '64px',
                    '-ms-interpolation-mode': 'nearest-neighbor',
                  }} />
              </Flex.Item>
              <Flex.Item grow={1} basis={0}>
                <LabeledList>
                  {entry.nickname && (
                    <LabeledList.Item label="Nickname">
                      {entry.nickname}
                    </LabeledList.Item>
                  )}
                  <LabeledList.Item label="Species">
                    {entry.real_name}
                  </LabeledList.Item>
                  <LabeledList.Item label="Level">
                    {entry.level}
                  </LabeledList.Item>
                  <LabeledList.Item label="Primary Type">
                    {entry.type1}
                  </LabeledList.Item>
                  {entry.type2 && (
                    <LabeledList.Item label="Secondary Type">
                      {entry.type2}
                    </LabeledList.Item>
                  )}
                  <LabeledList.Item label="Actions">
                    <Button
                      content="Transfer"
                      icon="sd-card"
                      onClick={() => act('Transfer')} />
                    <Button
                      content="Release"
                      icon="arrow-up"
                      onClick={() => act('Release')} />
                    <Button
                      content="Rename"
                      icon="pencil-alt"
                      onClick={() => act('Rename')} />
                    {!!entry.is_hacked && (
                      <Button
                        content="Set Trap"
                        icon="bolt"
                        color="red"
                        onClick={() => act('Set_Trap')} />
                    )}
                  </LabeledList.Item>
                </LabeledList>
              </Flex.Item>
            </Flex>
          ) : (
            <Box color="red">
              Mob entry missing!
            </Box>
          )
        )}
      </Section>
    </Box>
  );
};
