import { createSearch } from 'common/string';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Button, LabeledList, Box, Section, NoticeBox, Tabs, Icon, Table, Input } from '../components';
import { Window } from '../layouts';

export const RndNetController = (props, context) => {
  const { act, data } = useBackend(context);
  const { ion } = data;
  const [tabIndex, setTabIndex] = useLocalState(context, 'mainTabIndex', 0);

  const PickTab = (index) => {
    switch (index) {
      case 0:
        return <NetworkPage />;
      case 1:
        return <DesignPage />;
      default:
        return 'SOMETHING WENT VERY WRONG PLEASE AHELP';
    }
  };

  return (
    <Window width={900} height={600}>
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab key="ConfigPage" icon="wrench" selected={tabIndex === 0} onClick={() => setTabIndex(0)}>
            Network Management
          </Tabs.Tab>
          <Tabs.Tab key="DesignPage" icon="floppy-disk" selected={tabIndex === 1} onClick={() => setTabIndex(1)}>
            Design Management
          </Tabs.Tab>
        </Tabs>
        {PickTab(tabIndex)}
      </Window.Content>
    </Window>
  );
};

const NetworkPage = (_properties, context) => {
  const { act, data } = useBackend(context);

  const [filterType, setFilterType] = useLocalState(context, 'filterType', 'ALL');

  const { network_password, network_name, devices } = data;

  let filters = [];
  filters.push(filterType);

  if (filterType === 'MSC') {
    filters.push('BCK');
    filters.push('PGN');
  }

  const filtered_devices = filterType === 'ALL' ? devices : devices.filter((x) => filters.indexOf(x.dclass) > -1);

  return (
    <>
      <Section title="Network Configuration">
        <LabeledList>
          <LabeledList.Item label="Network Name">
            <Button
              content={network_name ? network_name : 'Unset'}
              selected={network_name}
              icon="edit"
              onClick={() => act('network_name')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Network Password">
            <Button
              content={network_password ? network_password : 'Unset'}
              selected={network_password}
              icon="lock"
              onClick={() => act('network_password')}
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>

      <Section title="Connected Devices">
        <Tabs>
          <Tabs.Tab
            key="AllDevices"
            selected={filterType === 'ALL'}
            onClick={() => setFilterType('ALL')}
            icon="network-wired"
          >
            All Devices
          </Tabs.Tab>

          <Tabs.Tab key="RNDServers" selected={filterType === 'SRV'} onClick={() => setFilterType('SRV')} icon="server">
            R&D Servers
          </Tabs.Tab>

          <Tabs.Tab
            key="RDConsoles"
            selected={filterType === 'RDC'}
            onClick={() => setFilterType('RDC')}
            icon="desktop"
          >
            R&D Consoles
          </Tabs.Tab>

          <Tabs.Tab key="Mechfabs" selected={filterType === 'MFB'} onClick={() => setFilterType('MFB')} icon="industry">
            Exosuit Fabricators
          </Tabs.Tab>

          <Tabs.Tab key="Misc" selected={filterType === 'MSC'} onClick={() => setFilterType('MSC')} icon="microchip">
            Miscellaneous Devices
          </Tabs.Tab>
        </Tabs>

        <Table m="0.5rem">
          <Table.Row header>
            <Table.Cell>Device Name</Table.Cell>
            <Table.Cell>Device ID</Table.Cell>
            <Table.Cell>Unlink</Table.Cell>
          </Table.Row>
          {filtered_devices.map((d) => (
            <Table.Row key={d.id}>
              <Table.Cell>{d.name}</Table.Cell>
              <Table.Cell>{d.id}</Table.Cell>
              <Table.Cell>
                <Button
                  content="Unlink"
                  icon="unlink"
                  color="red"
                  onClick={() =>
                    act('unlink_device', {
                      dclass: d.dclass,
                      uid: d.id,
                    })
                  }
                />
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Section>
    </>
  );
};

const DesignPage = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { designs } = data;
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');

  return (
    <Section title="Design Management">
      <Input fluid placeholder="Search for designs" mb={2} onInput={(e, value) => setSearchText(value)} />
      {designs
        .filter(
          createSearch(searchText, (entry) => {
            return entry.name;
          })
        )
        .map((entry) => (
          <Button.Checkbox
            fluid
            key={entry.name}
            content={entry.name}
            checked={!entry.blacklisted}
            onClick={() => act(entry.blacklisted ? 'unblacklist_design' : 'blacklist_design', { d_uid: entry.uid })}
          />
        ))}
    </Section>
  );
};
