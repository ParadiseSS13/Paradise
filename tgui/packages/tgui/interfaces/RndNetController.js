import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import {
  Button,
  LabeledList,
  Box,
  Section,
  NoticeBox,
  Tabs,
  Icon,
  Table,
} from '../components';
import { Window } from '../layouts';

export const RNDNetworkController = (props, context) => {
  const {act, data} = useBackend(context);

  const [filterType, setFilterType] = useLocalState(context, 'filterType', 'ALL');

  const {
    network_password,
    network_name,
    devices
  } = data;

  const filtered_devices = (filterType === 'ALL' ? devices : devices.filter(x => x.dclass === filterType));

  return (
    <Window>
      <Window.Content scrollable>
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
              selected={filterType === "ALL"}
              onClick={() => setFilterType("ALL")}
            >
              <Icon name="network-wired" />
              All Devices
            </Tabs.Tab>

            <Tabs.Tab
              key="RNDServers"
              selected={filterType === "SRV"}
              onClick={() => setFilterType("SRV")}
            >
              <Icon name="server" />
              R&D Servers
            </Tabs.Tab>

            <Tabs.Tab
              key="RDConsoles"
              selected={filterType === "RDC"}
              onClick={() => setFilterType("RDC")}
            >
              <Icon name="desktop" />
              R&D Consoles
            </Tabs.Tab>

            <Tabs.Tab
              key="Mechfabs"
              selected={filterType === "MFB"}
              onClick={() => setFilterType("MFB")}
            >
              <Icon name="industry" />
              Exosuit Fabricators
            </Tabs.Tab>

            <Tabs.Tab
              key="Misc"
              selected={filterType === "PNG"}
              onClick={() => setFilterType("PNG")}
            >
              <Icon name="microchip" />
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
                        uid: d.id
                      })
                    }
                  />
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
}
