import { Box, Button, Divider, Icon, LabeledList, NumberInput, Section, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { createLogger } from '../logging';

const logger = createLogger('OreRedemption');

const formatPoints = (amt) => amt.toLocaleString('en-US') + ' pts';

export const OreRedemption = (properties) => {
  return (
    <Window width={490} height={750}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <IdDisk height="100%" />
          </Stack.Item>
          <Sheet />
          <Alloy />
        </Stack>
      </Window.Content>
    </Window>
  );
};

const IdDisk = (properties) => {
  const { act, data } = useBackend();
  const { id, points, disk } = data;
  const { ...rest } = properties;
  return (
    <Section {...rest}>
      <Box color="average" textAlign="center">
        <Icon name="exclamation-triangle" mr="0.5rem" />
        This machine only accepts ore. Gibtonite is not accepted.
      </Box>
      <Divider />
      <LabeledList>
        <LabeledList.Item label="Unclaimed Points" color={points > 0 ? 'good' : 'grey'} bold={points > 0 && 'good'}>
          {formatPoints(points)}
        </LabeledList.Item>
      </LabeledList>
      <Divider />
      {disk ? (
        <LabeledList>
          <LabeledList.Item label="Design disk">
            <Button
              selected
              bold
              icon="eject"
              content={disk.name}
              tooltip="Ejects the design disk."
              onClick={() => act('eject_disk')}
            />
            <Button
              disabled={!disk.design || !disk.compatible}
              icon="upload"
              content="Download"
              tooltip="Downloads the design on the disk into the machine."
              onClick={() => act('download')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Stored design">
            <Box color={disk.design && (disk.compatible ? 'good' : 'bad')}>{disk.design || 'N/A'}</Box>
          </LabeledList.Item>
        </LabeledList>
      ) : (
        <Box color="label">No design disk inserted.</Box>
      )}
    </Section>
  );
};

/*
Manages titles under "Sheet"
*/

const Sheet = (properties) => {
  const { act, data } = useBackend();
  const { sheets } = data;
  const { ...rest } = properties;
  return (
    <Stack.Item grow height="20%">
      <Section fill scrollable className="OreRedemption__Ores" p="0" {...rest}>
        <OreHeader
          title="Sheets"
          columns={[
            ['Available', '25%'],
            ['Ore Value', '15%'],
            ['Smelt', '20%'],
          ]}
        />
        {sheets.map((sheet) => (
          <SheetLine key={sheet.id} ore={sheet} />
        ))}
      </Section>
    </Stack.Item>
  );
};

/*
Manages titles under "Alloy"
*/

const Alloy = (properties) => {
  const { act, data } = useBackend();
  const { alloys } = data;
  const { ...rest } = properties;
  return (
    <Stack.Item grow>
      <Section fill scrollable className="OreRedemption__Ores" p="0" {...rest}>
        <OreHeader
          title="Alloys"
          columns={[
            ['Recipe', '50%'],
            ['Available', '11%'],
            ['Smelt', '20%'],
          ]}
        />
        {alloys.map((alloy) => (
          <AlloyLine key={alloy.id} ore={alloy} />
        ))}
      </Section>
    </Stack.Item>
  );
};

const OreHeader = (properties) => {
  return (
    <Box className="OreHeader">
      <Stack fill>
        <Stack.Item grow>{properties.title}</Stack.Item>
        {properties.columns?.map((col) => (
          <Stack.Item key={col} basis={col[1]} textAlign="center" color="label" bold>
            {col[0]}
          </Stack.Item>
        ))}
      </Stack>
    </Box>
  );
};

/*
 ********* SHEETS BOX PROPERTIES *********
 */

const SheetLine = (properties) => {
  const { act } = useBackend();
  const { ore } = properties;
  if (ore.value && ore.amount <= 0 && !(['metal', 'glass'].indexOf(ore.id) > -1)) {
    return;
  }
  return (
    <Box className="SheetLine">
      <Stack fill>
        <Stack.Item basis="45%" align="middle">
          <Stack align="center">
            <Stack.Item className={classes(['materials32x32', ore.id])} />
            <Stack.Item>{ore.name}</Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item
          basis="20%"
          textAlign="center"
          color={ore.amount >= 1 ? 'good' : 'gray'}
          bold={ore.amount >= 1}
          align="center"
        >
          {ore.amount.toLocaleString('en-US')}
        </Stack.Item>
        <Stack.Item basis="20%" textAlign="center" align="center">
          {ore.value}
        </Stack.Item>
        <Stack.Item basis="20%" textAlign="center" align="center" lineHeight="32px">
          <NumberInput
            width="40%"
            value={0}
            minValue={0}
            maxValue={Math.min(ore.amount, 50)}
            step={1}
            stepPixelSize={6}
            onChange={(value) =>
              act(ore.value ? 'sheet' : 'alloy', {
                'id': ore.id,
                'amount': value,
              })
            }
          />
        </Stack.Item>
      </Stack>
    </Box>
  );
};

/*
 ********* ALLOYS BOX PROPERTIES *********
 */

const AlloyLine = (properties) => {
  const { act } = useBackend();
  const { ore } = properties;
  return (
    <Box className="SheetLine">
      <Stack fill>
        <Stack.Item basis="7%" align="middle">
          <Box className={classes(['alloys32x32', ore.id])} />
        </Stack.Item>
        <Stack.Item basis="30%" textAlign="middle" align="center">
          {ore.name}
        </Stack.Item>
        <Stack.Item basis="35%" textAlign="middle" color={ore.amount >= 1 ? 'good' : 'gray'} align="center">
          {ore.description}
        </Stack.Item>
        <Stack.Item
          basis="10%"
          textAlign="center"
          color={ore.amount >= 1 ? 'good' : 'gray'}
          bold={ore.amount >= 1}
          align="center"
        >
          {ore.amount.toLocaleString('en-US')}
        </Stack.Item>
        <Stack.Item basis="20%" textAlign="center" align="center" lineHeight="32px">
          <NumberInput
            width="40%"
            value={0}
            minValue={0}
            maxValue={Math.min(ore.amount, 50)}
            stepPixelSize={6}
            step={1}
            onChange={(value) =>
              act(ore.value ? 'sheet' : 'alloy', {
                'id': ore.id,
                'amount': value,
              })
            }
          />
        </Stack.Item>
      </Stack>
    </Box>
  );
};
