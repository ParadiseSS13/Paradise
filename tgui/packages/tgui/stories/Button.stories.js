/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { useLocalState } from '../backend';
import { Box, Button, Section } from '../components';

export const meta = {
  title: 'Button',
  render: () => <Story />,
};

const COLORS_SPECTRUM = [
  'red',
  'orange',
  'yellow',
  'olive',
  'green',
  'teal',
  'blue',
  'violet',
  'purple',
  'pink',
  'brown',
  'grey',
  'gold',
];

const COLORS_STATES = ['good', 'average', 'bad', 'black', 'white'];

const Story = (props, context) => {
  const [translucent, setTranslucent] = useLocalState(context, 'translucent', false);

  return (
    <>
      <Section>
        <Box mb={1}>
          <Button content="Simple" />
          <Button selected content="Selected" />
          <Button altSelected content="Alt Selected" />
          <Button disabled content="Disabled" />
          <Button color="transparent" content="Transparent" />
          <Button icon="cog" content="Icon" />
          <Button icon="power-off" />
          <Button fluid content="Fluid" />
          <Button my={1} lineHeight={2} minWidth={15} textAlign="center" content="With Box props" />
        </Box>
      </Section>
      <Section
        title="Color States"
        buttons={
          <Button.Checkbox checked={translucent} onClick={() => setTranslucent(!translucent)} content="Translucent" />
        }
      >
        {COLORS_STATES.map((color) => (
          <Button key={color} translucent={translucent} color={color} content={color} />
        ))}
      </Section>
      <Section title="Available Colors">
        {COLORS_SPECTRUM.map((color) => (
          <Button key={color} translucent={translucent} color={color} content={color} />
        ))}
      </Section>
      <Section title="Text Colors">
        {COLORS_SPECTRUM.map((color) => (
          <Box inline mx="7px" key={color} color={color}>
            {color}
          </Box>
        ))}
      </Section>
    </>
  );
};
