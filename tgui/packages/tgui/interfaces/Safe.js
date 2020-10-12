import { useBackend } from "../backend";
import { Window } from "../layouts";
import { Box, Button, Flex, Section } from "../components";
const safeDialSrc = require('../assets/safe_dial.png');

export const SafeContents = (properties, context) => {
  const { data, act } = useBackend(context);
  const {
    contents,
  } = data;

  const close = () => {
    act('open');
  };

  return (
    <Section>
      <Button content="Close" onClick={close} />
      <Section>
        {contents.map((content, i) => {
          const {
            name, index, sprite,
          } = content;
          const retrieve = () => {
            act('retrieve', { index });
          };
          const src = `${sprite}.png`;
          return (
            <Flex alignItems="center" key={i}>
              <img src={src} />
              <Button content={name} onClick={retrieve} />
            </Flex>
          );
        })}
      </Section>
    </Section>
  );
};

export const SafeLock = (properties, context) => {
  const { data, act } = useBackend(context);
  const {
    dial, rotation, locked,
  } = data;
  const open = () => {
    act('open');
  };
  const turn = (direction, amount) => {
    act('turn', { amount, direction });
  };

  return (
    <Section>

      <Flex alignItems="stretch" flexDirection="column">

        <Flex alignItems="center" flexDirection="column">
          <Button content="Open" onClick={open} />

        </Flex>

        <Flex justifyContent="space-between" alignItems="center">
          <Flex>

            <Button content="Left 50" onClick={() => turn('left', 50)} icon="arrow-left" />
            <Button content="Left 10" onClick={() => turn('left', 10)} icon="arrow-left" />
            <Button content="Left 1" onClick={() => turn('left', 1)} icon="arrow-left" />
          </Flex>

          <Flex flexGrow={1} alignItems="center" flexDirection="column">
            {dial}
          </Flex>

          <Flex>

            <Button disabled={!locked} content="Right 1" onClick={() => turn('right', 1)} icon="arrow-left" />
            <Button disabled={!locked} content="Right 10" onClick={() => turn('right', 10)} icon="arrow-left" />
            <Button disabled={!locked} content="Right 50" onClick={() => turn('right', 50)} icon="arrow-left" />
          </Flex>

        </Flex>

        <Flex alignItems="center" flexDirection="column">

          <Box className="Safe__Dial" style={{
            transform: `rotate(${rotation})`,
          }} />
        </Flex>


        <Box>
          <Box bold>How to open your Scarborough Arms tumbler safe.</Box>
          <Box>
            <Box>1. Turn the dial right to the first number.</Box>
            <Box>2. Turn the dial left to the second number.</Box>
            <Box>3. Continue repeating this process for each number, switching between right and left each time.</Box>
            <Box>4. Open the safe.</Box>
          </Box>
          <Box bold>To lock fully, turn the dial to the left after closing the safe.</Box>
        </Box>
      </Flex>

    </Section>
  );
};

export const Safe = (properties, context) => {
  const { data, act } = useBackend(context);
  const {
    open,
  } = data;
  return (
    <Window className="Safe">
      <Window.Content>
        {open ? <SafeContents /> : <SafeLock />}
      </Window.Content>
    </Window>
  );
};
