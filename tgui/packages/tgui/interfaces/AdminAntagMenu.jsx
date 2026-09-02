import { useContext } from 'react';
import {
  Box,
  Button,
  Icon,
  Input,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Table,
  Tabs,
  Tooltip,
} from 'tgui-core/components';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import SearchableTableContext from './common/SearchableTableContext';
import SortableTableContext from './common/SortableTableContext';
import TabsContext from './common/TabsContext';

const PickTitle = (index) => {
  switch (index) {
    case 0:
      return 'Antagonists';
    case 1:
      return 'Objectives';
    case 2:
      return 'Security';
    case 3:
      return 'All High Value Items';
    case 4:
      return 'Advanced Disease Carriers';
    default:
      return 'Something went wrong with this menu, make an issue report please!';
  }
};

const PickTab = (index) => {
  switch (index) {
    case 0:
      return <AntagList />;
    case 1:
      return <Objectives />;
    case 2:
      return <Security />;
    case 3:
      return <HighValueItems />;
    case 4:
      return <AdvancedDiseaseCarriers />;
    default:
      return 'Something went wrong with this menu, make an issue report please!';
  }
};

export const AdminAntagMenu = (properties) => {
  return (
    <Window width={800} height={600}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <NoticeBox>
              This menu is a Work in Progress. Some antagonists like Nuclear Operatives and Biohazards will not show up.
            </NoticeBox>
          </Stack.Item>
          <TabsContext.Default tabIndex={0}>
            <Stack.Item>
              <AdminAntagMenuNavigation />
            </Stack.Item>
            <Stack.Item grow>
              <AdminAntagMenuContent />
            </Stack.Item>
          </TabsContext.Default>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const AdminAntagMenuNavigation = () => {
  const { tabIndex, setTabIndex } = useContext(TabsContext);
  return (
    <Tabs>
      <Tabs.Tab
        key="Antagonists"
        selected={tabIndex === 0}
        onClick={() => {
          setTabIndex(0);
        }}
        icon="user"
      >
        Antagonists
      </Tabs.Tab>
      <Tabs.Tab
        key="Objectives"
        selected={tabIndex === 1}
        onClick={() => {
          setTabIndex(1);
        }}
        icon="people-robbery"
      >
        Objectives
      </Tabs.Tab>
      <Tabs.Tab
        key="Security"
        selected={tabIndex === 2}
        onClick={() => {
          setTabIndex(2);
        }}
        icon="handcuffs"
      >
        Security
      </Tabs.Tab>
      <Tabs.Tab
        key="HighValueItems"
        selected={tabIndex === 3}
        onClick={() => {
          setTabIndex(3);
        }}
        icon="lock"
      >
        High Value Items
      </Tabs.Tab>
      <Tabs.Tab
        key="AdvancedDiseaseCarriers"
        selected={tabIndex === 4}
        onClick={() => {
          setTabIndex(4);
        }}
        icon="virus"
      >
        Advanced Disease Carriers
      </Tabs.Tab>
    </Tabs>
  );
};

const AdminAntagMenuContent = () => (
  <SearchableTableContext.Default>
    <AdminAntagMenuContentBase />
  </SearchableTableContext.Default>
);

const AdminAntagMenuContentBase = () => {
  const { act } = useBackend();
  const { tabIndex } = useContext(TabsContext);
  const { setSearchText } = useContext(SearchableTableContext);
  return (
    <Section
      title={PickTitle(tabIndex)}
      fill
      scrollable
      buttons={
        <Stack fill>
          <Input width="300px" placeholder="Search..." onChange={(value) => setSearchText(value)} />
          <Button icon="sync" onClick={() => act('refresh')}>
            Refresh
          </Button>
        </Stack>
      }
    >
      {PickTab(tabIndex)}
    </Section>
  );
};

const AntagList = () => (
  <SortableTableContext.Default sortId="antag_name">
    <AntagListBase />
  </SortableTableContext.Default>
);

const AntagListBase = (properties) => {
  const { act, data } = useBackend();
  const { antagonists } = data;
  const { searchText } = useContext(SearchableTableContext);
  const { sortId, sortOrder } = useContext(SortableTableContext);
  if (!antagonists.length) {
    return 'No Antagonists!';
  }
  return (
    <Table className="AdminAntagMenu__list">
      <Table.Row bold>
        <SortButton id="name">Mob Name</SortButton>
        <SortButton id="">Buttons</SortButton>
        <SortButton id="antag_name">Antagonist Type</SortButton>
        <SortButton id="status">Status</SortButton>
      </Table.Row>
      {antagonists
        .filter(
          createSearch(searchText, (antag) => {
            return antag.name + '|' + antag.status + '|' + antag.antag_name;
          })
        )
        .sort((a, b) => {
          const i = sortOrder ? 1 : -1;
          if (a[sortId] === undefined || a[sortId] === null) {
            return i;
          }
          if (b[sortId] === undefined || b[sortId] === null) {
            return -1 * i;
          }
          if (typeof a[sortId] === 'number') {
            return (a[sortId] - b[sortId]) * i;
          }
          return a[sortId].localeCompare(b[sortId]) * i;
        })
        .map((antag, index) => (
          <Table.Row key={index}>
            <Table.Cell collapsing>
              {!antag.body_destroyed ? (
                <Button
                  color={antag.is_hijacker || !antag.name ? 'red' : ''}
                  tooltip={antag.is_hijacker ? 'Hijacker' : ''}
                  onClick={() =>
                    act('show_player_panel', {
                      mind_uid: antag.antag_mind_uid,
                    })
                  }
                >
                  {antag.name ? antag.name : '??? (NO NAME)'}
                </Button>
              ) : (
                antag.name
              )}
            </Table.Cell>
            <Table.Cell collapsing>
              <Button
                onClick={() => {
                  act('pm', {
                    ckey: antag.ckey,
                  });
                }}
              >
                PM
              </Button>
              <Button
                onClick={() => {
                  act('follow', {
                    datum_uid: antag.antag_mind_uid,
                  });
                }}
              >
                FLW
              </Button>
              <Button
                onClick={() => {
                  act('obs', {
                    mind_uid: antag.antag_mind_uid,
                  });
                }}
              >
                OBS
              </Button>
              <Button
                onClick={() => {
                  act('tp', {
                    mind_uid: antag.antag_mind_uid,
                  });
                }}
              >
                TP
              </Button>
            </Table.Cell>
            <Table.Cell>{antag.antag_name}</Table.Cell>
            <Table.Cell>
              <Box color={antag.status ? 'red' : 'grey'}>{antag.status ? antag.status : 'Alive'}</Box>
            </Table.Cell>
          </Table.Row>
        ))}
    </Table>
  );
};

const Objectives = () => (
  <SortableTableContext.Default sortId="target_name">
    <ObjectivesBase />
  </SortableTableContext.Default>
);

const ObjectivesBase = (properties) => {
  const { act, data } = useBackend();
  const { objectives } = data;
  const { searchText } = useContext(SearchableTableContext);
  const { sortId, sortOrder } = useContext(SortableTableContext);
  if (!objectives.length) {
    return 'No Objectives!';
  }
  return (
    <Table className="AdminAntagMenu__list">
      <Table.Row bold>
        <SortButton sort_group="sortId2" id="obj_name">
          Name
        </SortButton>
        <SortButton sort_group="sortId2" id="target_name">
          Target
        </SortButton>
        <SortButton sort_group="sortId2" id="status">
          Status
        </SortButton>
        <SortButton sort_group="sortId2" id="owner_name">
          Owner
        </SortButton>
      </Table.Row>
      {objectives
        .filter(
          createSearch(searchText, (objective) => {
            return (
              objective.obj_name +
              '|' +
              objective.target_name +
              '|' +
              (objective.status ? 'success' : 'incompleted') +
              '|' +
              objective.owner_name
            );
          })
        )
        .sort((a, b) => {
          const i = sortOrder ? 1 : -1;
          if (a[sortId] === undefined || a[sortId] === null || (sortId === 'target_name' && a.no_target)) {
            return i;
          }
          if (b[sortId] === undefined || b[sortId] === null || (sortId === 'target_name' && b.no_target)) {
            return -1 * i;
          }
          if (typeof a[sortId] === 'number') {
            return (a[sortId] - b[sortId]) * i;
          }
          return a[sortId].localeCompare(b[sortId]) * i;
        })
        .map((objective, index) => (
          <Table.Row key={index}>
            <Table.Cell>
              <Button
                tooltip={objective.obj_desc}
                onClick={() =>
                  act('vv', {
                    uid: objective.obj_uid,
                  })
                }
              >
                {objective.obj_name}
              </Button>
            </Table.Cell>
            <Table.Cell>
              {objective.no_target
                ? ''
                : objective.track.length
                  ? objective.track.map((target, index) => (
                      <Button
                        key={index}
                        onClick={() =>
                          act('follow', {
                            datum_uid: target,
                          })
                        }
                      >
                        {objective.target_name}{' '}
                        {objective.track.length > 1 ? '(' + (parseInt(index, 10) + 1) + ')' : ''}
                      </Button>
                    ))
                  : 'No ' + objective.target_name + ' Found'}
            </Table.Cell>
            <Table.Cell>
              <Box color={objective.status ? 'green' : 'grey'}>{objective.status ? 'Success' : 'Incomplete'}</Box>
            </Table.Cell>
            <Table.Cell collapsing>
              <Button
                onClick={() => {
                  act('obj_owner', {
                    owner_uid: objective.owner_uid,
                  });
                }}
              >
                {objective.owner_name}
              </Button>
            </Table.Cell>
          </Table.Row>
        ))}
    </Table>
  );
};

const Security = () => (
  <SortableTableContext.Default sortId="health">
    <SecurityBase />
  </SortableTableContext.Default>
);

const SecurityBase = (properties) => {
  const { act, data } = useBackend();
  const { security } = data;
  const { searchText } = useContext(SearchableTableContext);
  const { sortId, sortOrder } = useContext(SortableTableContext);

  const getColor = (officer) => {
    if (officer.status === 2) {
      return 'red';
    }
    if (officer.status === 1) {
      return 'orange';
    }
    if (officer.broken_bone || officer.internal_bleeding) {
      return 'yellow';
    }
    return 'grey';
  };
  const getStatus = (officer) => {
    if (officer.status === 2) {
      return 'Dead';
    }
    if (officer.status === 1) {
      return 'Unconscious';
    }
    if (officer.broken_bone && officer.internal_bleeding) {
      return 'Broken Bone, IB';
    }
    if (officer.broken_bone) {
      return 'Broken Bone';
    }
    if (officer.internal_bleeding) {
      return 'IB';
    }
    return 'Alive';
  };

  if (!security.length) {
    return 'No Security!';
  }
  return (
    <Table className="AdminAntagMenu__list">
      <Table.Row bold>
        <SortButton sort_group="sortId3" id="name">
          Name
        </SortButton>
        <SortButton sort_group="sortId3" id="role">
          Role
        </SortButton>
        <SortButton sort_group="sortId3" id="status">
          Status
        </SortButton>
        <SortButton sort_group="sortId3" id="antag">
          Antag
        </SortButton>
        <SortButton sort_group="sortId3" id="health">
          Health
        </SortButton>
      </Table.Row>
      {security
        .filter(
          createSearch(searchText, (officer) => {
            return officer.name + '|' + officer.role + '|' + getStatus(officer) + '|' + officer.antag;
          })
        )
        .sort((a, b) => {
          const i = sortOrder ? 1 : -1;
          if (a[sortId] === undefined || a[sortId] === null) {
            return i;
          }
          if (b[sortId] === undefined || b[sortId] === null) {
            return -1 * i;
          }
          if (typeof a[sortId] === 'number') {
            return (a[sortId] - b[sortId]) * i;
          }
          return a[sortId].localeCompare(b[sortId]) * i;
        })
        .map((officer, index) => (
          <Table.Row key={index}>
            <Table.Cell collapsing>
              <Button
                onClick={() =>
                  act('show_player_panel', {
                    mind_uid: officer.mind_uid,
                  })
                }
              >
                {officer.name}
              </Button>
            </Table.Cell>
            <Table.Cell collapsing>{officer.role}</Table.Cell>
            <Table.Cell collapsing>
              <Box color={getColor(officer)}>{getStatus(officer)}</Box>
            </Table.Cell>
            <Table.Cell collapsing>
              {officer.antag ? (
                <Button
                  textColor="red"
                  onClick={() => {
                    act('tp', {
                      mind_uid: officer.mind_uid,
                    });
                  }}
                >
                  {officer.antag}
                </Button>
              ) : (
                ''
              )}
            </Table.Cell>
            <Table.Cell>
              <ProgressBar
                my={0.5}
                minValue={0}
                value={officer.health / officer.max_health}
                maxValue={1}
                ranges={{
                  good: [0.6, Infinity],
                  average: [0, 0.6],
                  bad: [-Infinity, 0],
                }}
              >
                {officer.health}
              </ProgressBar>
            </Table.Cell>
            <Table.Cell collapsing>
              <Button
                onClick={() => {
                  act('pm', {
                    ckey: officer.ckey,
                  });
                }}
              >
                PM
              </Button>
              <Button
                onClick={() => {
                  act('follow', {
                    datum_uid: officer.mind_uid,
                  });
                }}
              >
                FLW
              </Button>
              <Button
                onClick={() => {
                  act('obs', {
                    mind_uid: officer.mind_uid,
                  });
                }}
              >
                OBS
              </Button>
            </Table.Cell>
          </Table.Row>
        ))}
    </Table>
  );
};

const HighValueItems = () => (
  <SortableTableContext.Default sortId="person">
    <HighValueItemsBase />
  </SortableTableContext.Default>
);

const HighValueItemsBase = (properties) => {
  const { act, data } = useBackend();
  const { high_value_items } = data;
  const { searchText } = useContext(SearchableTableContext);
  const { sortId, sortOrder } = useContext(SortableTableContext);
  if (!high_value_items.length) {
    return 'No High Value Items!';
  }
  return (
    <Table className="AdminAntagMenu__list">
      <Table.Row bold>
        <SortButton sort_group="sortId4" id="name">
          Name
        </SortButton>
        <SortButton sort_group="sortId4" id="person">
          Carrier
        </SortButton>
        <SortButton sort_group="sortId4" id="loc">
          Location
        </SortButton>
        <SortButton sort_group="sortId4" id="admin_z">
          On Admin Z-level
        </SortButton>
      </Table.Row>
      {high_value_items
        .filter(
          createSearch(searchText, (item) => {
            return item.name + '|' + item.loc;
          })
        )
        .sort((a, b) => {
          const i = sortOrder ? 1 : -1;
          if (a[sortId] === undefined || a[sortId] === null) {
            return i;
          }
          if (b[sortId] === undefined || b[sortId] === null) {
            return -1 * i;
          }
          if (typeof a[sortId] === 'number') {
            return (a[sortId] - b[sortId]) * i;
          }
          return a[sortId].localeCompare(b[sortId]) * i;
        })
        .map((item, index) => (
          <Table.Row key={index}>
            <Table.Cell>
              <Button
                tooltip={item.obj_desc}
                onClick={() =>
                  act('vv', {
                    uid: item.uid,
                  })
                }
              >
                {item.name}
              </Button>
            </Table.Cell>
            <Table.Cell>
              <Box color={item.admin_z ? 'grey' : ''}>{item.person}</Box>
            </Table.Cell>
            <Table.Cell>
              <Box color={item.admin_z ? 'grey' : ''}>{item.loc}</Box>
            </Table.Cell>
            <Table.Cell>
              <Box color="grey">{item.admin_z ? 'On Admin Z-level' : ''}</Box>
            </Table.Cell>
            <Table.Cell collapsing>
              <Button
                onClick={() => {
                  act('follow', {
                    datum_uid: item.uid,
                  });
                }}
              >
                FLW
              </Button>
            </Table.Cell>
          </Table.Row>
        ))}
    </Table>
  );
};

const AdvancedDiseaseCarriers = () => (
  <SortableTableContext.Default sortId="strain">
    <AdvancedDiseaseCarriersBase />
  </SortableTableContext.Default>
);

const AdvancedDiseaseCarriersBase = (propertiest) => {
  const { act, data } = useBackend();
  const { disease_carriers, virus_data } = data;
  const { searchText } = useContext(SearchableTableContext);
  const { sortId, sortOrder } = useContext(SortableTableContext);

  const getColor = (carrier) => {
    if (carrier.status === 2) {
      return 'red';
    }
    if (carrier.status === 1) {
      return 'orange';
    }
    if (carrier.broken_bone || carrier.internal_bleeding) {
      return 'yellow';
    }
    return 'grey';
  };
  const getStatus = (carrier) => {
    if (carrier.status === 2) {
      return 'Dead';
    }
    if (carrier.status === 1) {
      return 'Unconscious';
    }
    return 'Alive';
  };

  if (!disease_carriers.length) {
    return 'No Disease Carriers!';
  }
  return (
    <Table className="AdminAntagMenu__list">
      <Table.Row bold>
        <SortButton sort_group="sortId4" id="name">
          Name
        </SortButton>
        <SortButton sort_group="sortId4" id="status">
          Status
        </SortButton>
        <SortButton sort_group="sortId4" id="virus_name">
          Virus Name
        </SortButton>
        <SortButton sort_group="sortId4" id="strain">
          Strain
        </SortButton>
        <SortButton sort_group="sortId4" id="progress">
          Progress
        </SortButton>
        <SortButton sort_group="sortId4" id="health">
          Health
        </SortButton>
      </Table.Row>
      {disease_carriers
        .filter(
          createSearch(searchText, (carrier) => {
            return carrier.name + '|' + '|' + getStatus(carrier) + '|' + carrier.strain + '|' + carrier.virus_name;
          })
        )
        .sort((a, b) => {
          const i = sortOrder ? 1 : -1;
          if (a[sortId] === undefined || a[sortId] === null) {
            return i;
          }
          if (b[sortId] === undefined || b[sortId] === null) {
            return -1 * i;
          }
          if (typeof a[sortId] === 'number') {
            return (a[sortId] - b[sortId]) * i;
          }
          return a[sortId].localeCompare(b[sortId]) * i;
        })
        .map((carrier, index) => (
          <Table.Row key={index}>
            <Table.Cell collapsing>
              <Button
                color={carrier.patient_zero ? 'red' : ''}
                onClick={() =>
                  act('show_player_panel', {
                    mind_uid: carrier.mind_uid,
                  })
                }
              >
                {carrier.name}
              </Button>
            </Table.Cell>
            <Table.Cell collapsing>
              <Box color={getColor(carrier)}>{getStatus(carrier)}</Box>
            </Table.Cell>
            <Table.Cell collapsing>{carrier.virus_name}</Table.Cell>
            <Tooltip key={index} position="right" content={'Symptoms: ' + virus_data[carrier.strain]}>
              <Table.Cell collapsing>{carrier.strain}</Table.Cell>
            </Tooltip>
            <Table.Cell>
              {carrier.patient_zero ? (
                'Patient Zero'
              ) : (
                <ProgressBar
                  minValue={0}
                  value={carrier.progress / 100}
                  maxValue={1}
                  ranges={{
                    good: [0, 20],
                    average: [20, 60],
                    bad: [60, 100],
                  }}
                >
                  {carrier.progress}
                </ProgressBar>
              )}
            </Table.Cell>
            <Table.Cell>
              <ProgressBar
                minValue={0}
                value={carrier.health / carrier.max_health}
                maxValue={1}
                ranges={{
                  good: [0.6, Infinity],
                  average: [0, 0.6],
                  bad: [-Infinity, 0],
                }}
              >
                {carrier.health}
              </ProgressBar>
            </Table.Cell>
            <Table.Cell collapsing>
              <Button
                onClick={() => {
                  act('pm', {
                    ckey: carrier.ckey,
                  });
                }}
              >
                PM
              </Button>
              <Button
                onClick={() => {
                  act('follow', {
                    datum_uid: carrier.mind_uid,
                  });
                }}
              >
                FLW
              </Button>
              <Button
                onClick={() => {
                  act('obs', {
                    mind_uid: carrier.mind_uid,
                  });
                }}
              >
                OBS
              </Button>
            </Table.Cell>
          </Table.Row>
        ))}
    </Table>
  );
};

const SortButton = (properties) => {
  const { id, sort_group = 'sortId', default_sort = 'antag_name', children } = properties;
  const { sortId, setSortId, sortOrder, setSortOrder } = useContext(SortableTableContext);
  return (
    <Table.Cell>
      <Button
        color={sortId !== id && 'transparent'}
        width="100%"
        onClick={() => {
          if (sortId === id) {
            setSortOrder(!sortOrder);
          } else {
            setSortId(id);
            setSortOrder(true);
          }
        }}
      >
        {children}
        {sortId === id && <Icon name={sortOrder ? 'sort-up' : 'sort-down'} ml="0.25rem;" />}
      </Button>
    </Table.Cell>
  );
};
