import { Component } from 'inferno';
import { useBackend } from '../backend';
import { Icon, Input, Stack, Table } from '../components';
import { Window } from '../layouts';
import { createSearch } from 'common/string';

type StaticReagentInformation = {
  name: string;
};

type VolatileReagentInformation = {
  volume: number;
  uid: string;
};

type StaticReagentInformationWithID = StaticReagentInformation & { id: string };

type ReagentInformation = StaticReagentInformationWithID &
  VolatileReagentInformation;

type FilteredReagentInformation = StaticReagentInformationWithID &
  Partial<VolatileReagentInformation>;

type StaticData = {
  reagentsInformation: Record<string, StaticReagentInformation>;
};

type VolatileData = {
  reagents: Record<string, VolatileReagentInformation>;
};

type ReagentsEditorState = {
  searchText: string;
};

type ReagentsEditorData = StaticData & VolatileData;

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
          .filter(
            ([reagentID, _]) => reagentsInContainer[reagentID] === undefined
          )
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
      .filter(({ id: reagentID, name }) =>
        createSearch(state.searchText, () => `${reagentID}|${name}`)({})
      )
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
          <Stack fill vertical>
            <Stack.Item>
              <Input
                fluid
                value={state.searchText}
                onChange={this.handleSearchChange}
              />
            </Stack.Item>
            <Stack.Item grow>
              <Table className="reagents-table">{reagentsRows}</Table>
            </Stack.Item>
          </Stack>
        </Window.Content>
      </Window>
    );
  }
}

// Row for a reagent with non-zero volume
const PresentReagentRow = (
  {
    reagent: { id: reagentID, name, uid, volume },
  }: { reagent: FilteredReagentInformation },
  context: unknown
) => {
  const { act } = useBackend<ReagentsEditorData>(context);
  return (
    <Table.Row className="reagent-row present-row">
      <Table.Cell className="volume-cell">
        <Icon
          className="volume-button edit-volume-button"
          name="syringe"
          color="red"
          onClick={() =>
            act('edit_volume', {
              uid,
            })
          }
        />
        <span className="volume-label">{volume}u</span>
      </Table.Cell>
      <Table.Cell className="reagent-name-cell">
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
        <Icon
          className="volume-button add-reagent-button"
          name="fill-drip"
          onClick={() => act('add_reagent', { reagentID })}
        />
      </Table.Cell>
      <Table.Cell className="reagent-name-cell reagent-absent">
        {reagentID} ({name})
      </Table.Cell>
    </Table.Row>
  );
};
