import { Component } from 'inferno';
import { useBackend } from '../backend';
import { Button, Icon, Input, Section, Stack, Table } from '../components';
import { Window } from '../layouts';
import { createSearch } from 'common/string';

type StaticReagentInformation = {
  name: string;
};

type VolatileReagentInformation = {
  volume: number | null;
  uid: string;
};

type FilteredReagentInformation = StaticReagentInformation & {
  id: string;
} & Partial<VolatileReagentInformation>;

type StaticData = {
  reagentsInformation: Record<string, StaticReagentInformation>;
};

type VolatileData = {
  reagents: Record<string, VolatileReagentInformation>;
};

type ReagentsEditorData = StaticData & VolatileData;

type ReagentsEditorState = {
  searchText: string;
};

// The linter is raising false-positives for unused state
/* eslint-disable react/no-unused-state */
export class ReagentsEditor extends Component<{}, ReagentsEditorState> {
  constructor(props: {}) {
    super(props);
    this.state = {
      searchText: '',
    };
  }

  handleSearchChange = (e: Event) => {
    const target = e.target as HTMLInputElement;
    this.setState({ searchText: target.value });
  };

  override render(props: {}, state: ReagentsEditorState, context: unknown) {
    const {
      act,
      data: { reagentsInformation, reagents: reagentsInContainer },
    } = useBackend<ReagentsEditorData>(this.context);

    let reagents = Object.entries(reagentsInContainer)
      .map(
        ([reagentID, reagent]): FilteredReagentInformation => ({
          ...reagent,
          ...reagentsInformation[reagentID],
          id: reagentID,
        })
      )
      .sort((a, b) => a.name.localeCompare(b.name));
    if (state.searchText !== '') {
      reagents = reagents.concat(
        Object.entries(reagentsInformation)
          .filter(([reagentID, _]) => reagentsInContainer[reagentID] === undefined)
          .map(
            ([reagentID, reagent]): FilteredReagentInformation => ({
              ...reagent,
              id: reagentID,
            })
          )
          .sort((a, b) => a.name.localeCompare(b.name))
      );
    }

    const reagentsRows = reagents
      .filter(({ id: reagentID, name }) => createSearch(state.searchText, () => `${reagentID}|${name}`)({}))
      .map((reagent) => {
        const { volume, uid } = reagent;
        return volume === undefined ? (
          <AbsentReagentRow key={uid} reagent={reagent} />
        ) : (
          <PresentReagentRow key={uid} reagent={reagent} />
        );
      });

    return (
      <Window width={400} height={480}>
        <Window.Content>
          <Section fill>
            <Stack fill vertical>
              <Stack.Item>
                <Stack fill horizontal>
                  <Stack.Item grow>
                    <Input fluid value={state.searchText} onChange={this.handleSearchChange} />
                  </Stack.Item>
                  <Stack.Item>
                    <Button icon="sync" tooltip="Update Reagent Amounts" onClick={() => act('update_total')} />
                  </Stack.Item>
                  <Stack.Item>
                    <Button icon="fire-alt" tooltip="Force Reagent Reaction" onClick={() => act('react_reagents')} />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item grow>
                <Table className="reagents-table">{reagentsRows}</Table>
              </Stack.Item>
            </Stack>
          </Section>
        </Window.Content>
      </Window>
    );
  }
}

// Row for a reagent with non-zero volume
const PresentReagentRow = (
  { reagent: { id: reagentID, name, uid, volume } }: { reagent: FilteredReagentInformation },
  context: unknown
) => {
  const { act } = useBackend<ReagentsEditorData>(context);
  return (
    <Table.Row className="reagent-row">
      <Table.Cell className="volume-cell">
        <div className="volume-actions-wrapper">
          <Button.Confirm
            className="condensed-button"
            icon="trash-alt"
            confirmIcon="question"
            iconColor="red"
            confirmContent=""
            color="none"
            confirmColor="none"
            onClick={() =>
              act('delete_reagent', {
                uid,
              })
            }
            mr="0.5em"
          />
          <Button
            className="condensed-button"
            icon="syringe"
            iconColor="green"
            color="none"
            onClick={() =>
              act('edit_volume', {
                uid,
              })
            }
          />
        </div>
        <span className="volume-label">{volume === null ? `NULL` : `${volume}u`}</span>
      </Table.Cell>
      <Table.Cell>
        {reagentID} ({name})
      </Table.Cell>
    </Table.Row>
  );
};

// Row for a reagent with zero volume
const AbsentReagentRow = (
  { reagent: { id: reagentID, name } }: { reagent: FilteredReagentInformation },
  context: unknown
) => {
  const { act } = useBackend<ReagentsEditorData>(context);
  return (
    <Table.Row className="reagent-row absent-row">
      <Table.Cell className="volume-cell">
        <Button
          className="condensed-button add-reagent-button"
          icon="fill-drip"
          color="none"
          onClick={() => act('add_reagent', { reagentID })}
        />
      </Table.Cell>
      <Table.Cell className="reagent-absent-name-cell">
        {reagentID} ({name})
      </Table.Cell>
    </Table.Row>
  );
};
