import { DmIcon, Icon, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type StaticMaterial = {
  name: string;
  iconState?: string;
  points?: number;
};

type Material = {
  id: string;
  amount: number;
};

type StaticData = {
  icon: string;
  staticMaterials: Record<string, StaticMaterial>;
  showPoints?: 0 | 1;
};
type NonStaticData = {
  materials: Material[];
};

type Data = StaticData & NonStaticData;

const alwaysVisible = new Set(['metal', 'glass']);

export const MaterialContainer = () => {
  return (
    <Window width={300} height={400}>
      <Window.Content>
        <Contents />
      </Window.Content>
    </Window>
  );
};

const Contents = () => {
  return (
    <Section fill scrollable title="Metals">
      <Table className="materials-table">
        <Table.Row header>
          <Table.Cell header pl="0.5rem" py="0.5rem">
            Material
          </Table.Cell>
          <Table.Cell header>Sheets</Table.Cell>
          <PointsHeader />
        </Table.Row>
        <MaterialRows />
      </Table>
    </Section>
  );
};

const PointsHeader = () => {
  const {
    data: { showPoints },
  } = useBackend<Data>();
  if (showPoints) {
    return <Table.Cell header>Points</Table.Cell>;
  }
};

const MaterialRows = () => {
  const {
    data: { materials },
  } = useBackend<Data>();
  return materials
    .filter((m) => m.amount >= 1 || alwaysVisible.has(m.id))
    .map((m) => <MaterialRow key={m.id} material={m} />);
};

const MaterialRow = ({ material: { id, amount } }: { material: Material }) => {
  const {
    data: {
      icon,
      showPoints,
      staticMaterials: {
        [id]: { iconState, name, points },
      },
    },
  } = useBackend<Data>();
  return (
    <Table.Row>
      <Table.Cell>
        {iconState ? (
          <DmIcon icon={icon} icon_state={iconState} verticalAlign="middle" />
        ) : (
          <Icon name="sheet-plastic" verticalAlign="middle" />
        )}
        {name ?? id}
      </Table.Cell>
      <Table.Cell color={amount >= 1 ? 'good' : 'gray'}>{amount}</Table.Cell>
      {!!showPoints && points && <Table.Cell>{points}</Table.Cell>}
    </Table.Row>
  );
};
