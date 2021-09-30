import { toTitleCase } from 'common/string';
import { useBackend } from '../backend';
import { Box, Button, ProgressBar, LabeledList, Section, Table } from '../components';
import { Window } from '../layouts';

export const LaborClaimConsole = (props, context) => {
  return (
    <Window>
      <Window.Content>
        <ShuttleControlSection />
        <MaterialValuesSection />
      </Window.Content>
    </Window>
  );
};

const ShuttleControlSection = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    can_go_home,
    emagged,
    id_inserted,
    id_name,
    id_points,
    id_goal,
    unclaimed_points,
  } = data;
  const bad_progress = emagged ? 0 : 1;
  const completionStatus = emagged ? "ERR0R" : (can_go_home ? "Completed!" : "Insufficient");
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Status">
          {((!!id_inserted && (
            <ProgressBar
              value={id_points / id_goal}
              ranges={{
                good: [bad_progress, Infinity],
                bad: [-Infinity, bad_progress],
              }}>
              {id_points + ' / ' + id_goal + ' ' + completionStatus}
            </ProgressBar>
          )) || (!!emagged && "ERR0R COMPLETED?!@") || "No ID inserted"
          )}
        </LabeledList.Item>
        <LabeledList.Item label="Shuttle controls">
          <Button fluid
            content="Move shuttle"
            disabled={!can_go_home}
            onClick={() => act('move_shuttle')} />
        </LabeledList.Item>
        <LabeledList.Item
          label="Unclaimed points">
          <Button fluid
            content={"Claim points (" + unclaimed_points + ")"}
            disabled={!id_inserted || !unclaimed_points}
            onClick={() => act('claim_points')} />
        </LabeledList.Item>
        <LabeledList.Item
          label="Inserted ID">
          <Button fluid
            content={id_inserted ? id_name : '-------------'}
            onClick={() => act('handle_id')} />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const MaterialValuesSection = (props, context) => {
  const { data } = useBackend(context);
  const {
    ores,
  } = data;
  return (
    <Section title="Material values">
      <Table>
        <Table.Row header>
          <Table.Cell>
            Material
          </Table.Cell>
          <Table.Cell collapsing textAlign="right">
            Value
          </Table.Cell>
        </Table.Row>
        {ores.map(ore => (
          <Table.Row key={ore.ore}>
            <Table.Cell>
              {toTitleCase(ore.ore)}
            </Table.Cell>
            <Table.Cell collapsing textAlign="right">
              <Box color="label" inline>
                {ore.value}
              </Box>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
