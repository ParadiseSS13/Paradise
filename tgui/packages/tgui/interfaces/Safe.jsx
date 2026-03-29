import { Fragment } from 'react';
import { Box, Button, Icon, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const Safe = (properties) => {
  const { act, data } = useBackend();
  const { dial, open, locked, contents } = data;
  return (
    <Window theme="safe" width={600} height={800}>
      <Window.Content>
        <Box className="Safe--engraving">
          <Dialer />
          <Box>
            <Box className="Safe--engraving--hinge" top="25%" />
            <Box className="Safe--engraving--hinge" top="75%" />
          </Box>
          <Icon className="Safe--engraving--arrow" name="long-arrow-alt-down" size="3" />
          <br />
          {open ? (
            <Contents />
          ) : (
            <Box
              as="img"
              className="Safe--dial"
              src="safe_dial.png"
              style={{
                transform: 'rotate(-' + 3.6 * dial + 'deg)',
                zIndex: 0,
              }}
            />
          )}
        </Box>
        {!open && <Help />}
      </Window.Content>
    </Window>
  );
};

const Dialer = (properties) => {
  const { act, data } = useBackend();
  const { dial, open, locked } = data;
  const dialButton = (amount, right) => {
    return (
      <Button
        disabled={open || (right && !locked)}
        icon={'arrow-' + (right ? 'right' : 'left')}
        content={(right ? 'Right' : 'Left') + ' ' + amount}
        iconRight={right}
        onClick={() =>
          act(!right ? 'turnright' : 'turnleft', {
            num: amount,
          })
        }
        style={{
          zIndex: 10,
        }}
      />
    );
  };
  return (
    <Box className="Safe--dialer">
      <Button
        disabled={locked}
        icon={open ? 'lock' : 'lock-open'}
        content={open ? 'Close' : 'Open'}
        mb="0.5rem"
        onClick={() => act('open')}
      />
      <br />
      <Box position="absolute">{[dialButton(50), dialButton(10), dialButton(1)]}</Box>
      <Box className="Safe--dialer--right" position="absolute" right="5px">
        {[dialButton(1, true), dialButton(10, true), dialButton(50, true)]}
      </Box>
      <Box className="Safe--dialer--number">{dial}</Box>
    </Box>
  );
};

const Contents = (properties) => {
  const { act, data } = useBackend();
  const { contents } = data;
  return (
    <Box className="Safe--contents" overflow="auto">
      {contents.map((item, index) => (
        <Fragment key={item}>
          <Button
            mb="0.5rem"
            onClick={() =>
              act('retrieve', {
                index: index + 1,
              })
            }
          >
            <Box as="img" src={item.sprite + '.png'} verticalAlign="middle" ml="-6px" mr="0.5rem" />
            {item.name}
          </Button>
          <br />
        </Fragment>
      ))}
    </Box>
  );
};

const Help = (properties) => {
  return (
    <Section className="Safe--help" title="Safe opening instructions (because you all keep forgetting)">
      <Box>
        1. Turn the dial left to the first number.
        <br />
        2. Turn the dial right to the second number.
        <br />
        3. Continue repeating this process for each number, switching between left and right each time.
        <br />
        4. Open the safe.
      </Box>
      <Box bold>To lock fully, turn the dial to the left after closing the safe.</Box>
    </Section>
  );
};
