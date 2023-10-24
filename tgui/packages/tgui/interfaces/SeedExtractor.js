import { useBackend } from '../backend';
import { Button, Section, Table, Box, NumberInput } from '../components';
import { Window } from '../layouts';

export const SeedExtractor = (props, context) => {
  const { act, data } = useBackend(context);
  const { stored_seeds, vend_amount } = data;

  return (
    <Window resizable>
      <Window.Content scrollable className="Layout__content--flexColumn">
        <Section title="Stored Seeds">
          <div className="CameraConsole__toolbarRight">
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
          </div>
          {stored_seeds?.length ? <SeedsContent /> : 'No Seeds'}
        </Section>
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
        <Table.Cell textAlign="middle">Stock</Table.Cell>
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
            <Button
              content="Vend"
              icon="arrow-circle-down"
              onClick={() =>
                act('vend', {
                  seedid: seed.id,
				  seedvariant: seed.variant,
                })
              }
            />
            &nbsp;({seed.amount} Left)
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};
