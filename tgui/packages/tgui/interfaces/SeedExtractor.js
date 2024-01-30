import { useBackend } from '../backend';
import { Button, Section, Table, Stack, NumberInput } from '../components';
import { Window } from '../layouts';

export const SeedExtractor = (props, context) => {
  const { act, data } = useBackend(context);
  const { stored_seeds, vend_amount } = data;

  return (
    <Window width={800} height={400}>
      <Window.Content>
        <Stack fill vertical>
          <Section
            fill
            scrollable
            title="Stored Seeds"
            buttons={
              <>
                Set Amount to be Vended:&nbsp;
                <NumberInput
                  animated
                  value={vend_amount}
                  width="40px"
                  minValue={1}
                  maxValue={25}
                  stepPixelSize={3}
                  onDrag={(e, value) =>
                    act('set_vend_amount', {
                      vend_amount: value,
                    })
                  }
                />
              </>
            }
          >
            {stored_seeds?.length ? <SeedsContent /> : 'No Seeds'}
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const SeedsContent = (props, context) => {
  const { act, data } = useBackend(context);
  const { stored_seeds } = data;

  return (
    <Table>
      <Table.Row bold>
        <Table.Cell>Name</Table.Cell>
        <Table.Cell>Lifespan</Table.Cell>
        <Table.Cell>Endurance</Table.Cell>
        <Table.Cell>Maturation</Table.Cell>
        <Table.Cell>Production</Table.Cell>
        <Table.Cell>Yield</Table.Cell>
        <Table.Cell>Potency</Table.Cell>
        <Table.Cell>Stock</Table.Cell>
      </Table.Row>
      {stored_seeds.map((seed, index) => (
        <Table.Row key={index}>
          <Table.Cell>
            <img
              src={`data:image/jpeg;base64,${seed.image}`}
              style={{
                'vertical-align': 'middle',
                width: '32px',
                margin: '0px',
                'margin-left': '0px',
              }}
            />
            {seed.name}
            {seed.variant ? ' (' + seed.variant + ')' : ''}
          </Table.Cell>
          <Table.Cell>{seed.lifespan}</Table.Cell>
          <Table.Cell>{seed.endurance}</Table.Cell>
          <Table.Cell>{seed.maturation}</Table.Cell>
          <Table.Cell>{seed.production}</Table.Cell>
          <Table.Cell>{seed.yield}</Table.Cell>
          <Table.Cell>{seed.potency}</Table.Cell>
          <Table.Cell>
            ({seed.amount} Left)&nbsp;
            <Button
              ml={1}
              content="Vend"
              icon="arrow-circle-down"
              onClick={() =>
                act('vend', {
                  seedid: seed.id,
                  seedvariant: seed.variant,
                })
              }
            />
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};
