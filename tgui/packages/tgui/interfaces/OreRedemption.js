import { useBackend } from '../backend';
import {
  Box,
  Button,
  Divider,
  Flex,
  Icon,
  LabeledList,
  NumberInput,
  Section,
} from '../components';
import { FlexItem } from '../components/Flex';
import { Window } from '../layouts';

const formatPoints = (amt) => amt.toLocaleString('en-US') + ' pts';

export const OreRedemption = (properties, context) => {
  return (
    <Window>
      <Window.Content>
        <Flex direction="column" width="100%" height="100%">
          <Flex.Item basis="content" mb="0.5rem">
            <IdDisk height="100%" />
          </Flex.Item>
          <Flex.Item grow="1" overflow="hidden">
            <Sheet height="43%" />
            <Alloy height="57%" />
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const IdDisk = (properties, context) => {
  const { act, data } = useBackend(context);
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
        <LabeledList.Item label="ID card">
          {id ? (
            <Button
              selected
              bold
              verticalAlign="middle"
              icon="eject"
              content={id.name}
              tooltip="Ejects the ID card."
              onClick={() => act('eject_id')}
              style={{
                'white-space': 'pre-wrap',
              }}
            />
          ) : (
            <Button
              icon="sign-in-alt"
              content="Insert"
              tooltip="Hold the ID card in your hand to insert."
              onClick={() => act('insert_id')}
            />
          )}
        </LabeledList.Item>
        {id && (
          <LabeledList.Item label="Collected points">
            <Box bold>{formatPoints(id.points)}</Box>
          </LabeledList.Item>
        )}
        <LabeledList.Item
          label="Unclaimed points"
          color={points > 0 ? 'good' : 'grey'}
          bold={points > 0 && 'good'}
        >
          {formatPoints(points)}
        </LabeledList.Item>
        <LabeledList.Item>
          <Button
            disabled={!id}
            icon="hand-holding-usd"
            content="Claim"
            onClick={() => act('claim')}
          />
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
          </LabeledList.Item>
          <LabeledList.Item label="Stored design">
            <Box color={disk.design && (disk.compatible ? 'good' : 'bad')}>
              {disk.design || 'N/A'}
            </Box>
          </LabeledList.Item>
          <LabeledList.Item>
            <Button
              disabled={!disk.design || !disk.compatible}
              icon="upload"
              content="Download"
              tooltip="Downloads the design on the disk into the machine."
              onClick={() => act('download')}
              mb="0"
            />
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

const Sheet = (properties, context) => {
  const { act, data } = useBackend(context);
  const { sheets } = data;
  const { ...rest } = properties;
  return (
    <Section className="OreRedemption__Ores" p="0" {...rest}>
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
  );
};

/*
Manages titles under "Alloy"
*/

const Alloy = (properties, context) => {
  const { act, data } = useBackend(context);
  const { alloys } = data;
  const { ...rest } = properties;
  return (
    <Section className="OreRedemption__Ores" p="0" {...rest}>
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
  );
};

const OreHeader = (properties, context) => {
  return (
    <Box className="OreHeader">
      <Flex width="100%">
        <Flex.Item grow="1">{properties.title}</Flex.Item>
        {properties.columns?.map((col) => (
          <Flex.Item
            key={col}
            basis={col[1]}
            textAlign="center"
            color="label"
            bold
          >
            {col[0]}
          </Flex.Item>
        ))}
      </Flex>
    </Box>
  );
};

/*
********* SHEETS BOX PROPERTIES *********
*/

const SheetLine = (properties, context) => {
  const { act } = useBackend(context);
  const { ore } = properties;
  if (
    ore.value &&
    ore.amount <= 0 &&
    !(['$metal', '$glass'].indexOf(ore.id) > -1)
  ) {
    return;
  }
  const cleanId = ore.id.replace('$', '');
  return (
    <Box className="SheetLine">
      <Flex width="100%">
        <Flex.Item basis="45%" align="middle">
          <Box
            as="img"
            src={'sheet-' + cleanId + '.png'}
            verticalAlign="middle"
            ml="0rem"
            />
            {ore.name}
          </Flex.Item>
          <Flex.Item
            basis="20%"
            textAlign="center"
            color={ore.amount > 0 ? 'good' : 'gray'}
            bold={ore.amount > 0}
            align="center"
          >
            {ore.amount.toLocaleString('en-US')}
          </Flex.Item>
          <Flex.Item
            basis="20%"
            textAlign="center"
            align="center"
            >
            {ore.value}
          </Flex.Item>
          <Flex.Item
            basis="20%"
            textAlign="center"
            align="center"
            lineHeight="32px"
          >
            <NumberInput
              value={0}
              minValue={0}
              maxValue={Math.min(ore.amount, 50)}
              stepPixelSize={6}
              onChange={(_e, value) =>
                act(ore.value ? 'sheet' : 'alloy', {
                  'id': ore.id,
                  'amount': value,
                })
              }
            />
          </Flex.Item>
      </Flex>
    </Box>
  );
};

/*
********* ALLOYS BOX PROPERTIES *********
*/

const AlloyLine = (properties, context) => {
  const { act } = useBackend(context);
  const { ore } = properties;
  const cleanId = ore.id.replace('$', '');
  return (
    <Box className="SheetLine">
      <Flex width="100%">
        <Flex.Item basis="7%" align="middle">
          <Box
            as="img"
            src={'sheet-' + (cleanId) + '.png'}
            verticalAlign="middle"
            ml="`0rem"
            />
            </Flex.Item>
                <FlexItem
                  basis="30%"
                  textAlign="middle"
                  align="center"
                >
                  {ore.name}
            </FlexItem>
                <Flex.Item
                  basis="35%"
                  textAlign="middle"
                  color={ore.amount > 0 ? 'good' : 'gray'}
                  align="center"
                >
                  {ore.description}
            </Flex.Item>
              <Flex.Item
                basis="10%"
                textAlign="center"
                color={ore.amount > 0 ? 'good' : 'gray'}
                bold={ore.amount > 0}
                align="center"
               >
                {ore.amount.toLocaleString('en-US')}
              </Flex.Item>
            <Flex.Item
              basis="20%"
              textAlign="center"
              align="center"
              lineHeight="32px"
            >
              <NumberInput
                value={0}
                minValue={0}
                maxValue={Math.min(ore.amount, 50)}
                stepPixelSize={6}
                onChange={(_e, value) =>
                  act(ore.value ? 'sheet' : 'alloy', {
                    'id': ore.id,
                    'amount': value,
                  })
                }
              />
            </Flex.Item>
       </Flex>
    </Box>
  );
};
