import { Button, DmIcon, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Ore = {
  id: string;
  name: string;
  amount: number;
  icon: string;
  icon_state: string;
};

type Data = {
  ores: Ore[];
};

export const OreBox = () => {
  const { act, data } = useBackend<Data>();

  return (
    <Window width={350} height={400}>
      <Window.Content>
        <Section
          fill
          scrollable
          title="Ore Box contents"
          buttons={
            <Button icon="eject" disabled={!data.ores.length} onClick={() => act('empty')}>
              Empty box
            </Button>
          }
        >
          <Table>
            {data.ores.map((ore) => (
              <Table.Row key={ore.id}>
                <Table.Cell collapsing>
                  <DmIcon icon={ore.icon} icon_state={ore.icon_state} verticalAlign="middle" />
                </Table.Cell>
                <Table.Cell>{ore.name}</Table.Cell>
                <Table.Cell collapsing textAlign="right">
                  {ore.amount}
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
