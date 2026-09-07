import { useState } from 'react';
import { Box, Button, LabeledList, NoticeBox, Section, Table, Tabs } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const TcommsCore = (props) => {
  const { act, data } = useBackend();
  const { ion } = data;
  const [tabIndex, setTabIndex] = useState(0);

  const PickTab = (index) => {
    switch (index) {
      case 0:
        return <ConfigPage />;
      case 1:
        return <LinkagePage />;
      case 2:
        return <FilteringPage />;
      default:
        return 'SOMETHING WENT VERY WRONG PLEASE AHELP';
    }
  };

  return (
    <Window width={900} height={520}>
      <Window.Content scrollable>
        {ion === 1 && <IonBanner />}
        <Tabs>
          <Tabs.Tab key="ConfigPage" icon="wrench" selected={tabIndex === 0} onClick={() => setTabIndex(0)}>
            Configuration
          </Tabs.Tab>
          <Tabs.Tab key="LinkagePage" icon="link" selected={tabIndex === 1} onClick={() => setTabIndex(1)}>
            Device Linkage
          </Tabs.Tab>
          <Tabs.Tab key="FilterPage" icon="user-times" selected={tabIndex === 2} onClick={() => setTabIndex(2)}>
            User Filtering
          </Tabs.Tab>
        </Tabs>
        {PickTab(tabIndex)}
      </Window.Content>
    </Window>
  );
};

const IonBanner = () => {
  // This entire thing renders on one line
  // Its just split in here to get past
  // the 80 char line limit
  return (
    <NoticeBox>
      ERROR: An Ionospheric overload has occured. Please wait for the machine to reboot. This cannot be manually done.
    </NoticeBox>
  );
};

const ConfigPage = (_properties) => {
  const { act, data } = useBackend();
  const {
    active,
    sectors_available,
    nttc_toggle_jobs,
    nttc_toggle_job_color,
    nttc_toggle_name_color,
    nttc_toggle_command_bold,
    nttc_job_indicator_type,
    nttc_setting_language,
    network_id,
  } = data;
  return (
    <>
      <Section title="Status">
        <LabeledList>
          <LabeledList.Item label="Machine Power">
            <Button
              content={active ? 'On' : 'Off'}
              selected={active}
              icon="power-off"
              onClick={() => act('toggle_active')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Sector Coverage">{sectors_available}</LabeledList.Item>
        </LabeledList>
      </Section>

      <Section title="Radio Configuration">
        <LabeledList>
          <LabeledList.Item label="Job Announcements">
            <Button
              content={nttc_toggle_jobs ? 'On' : 'Off'}
              selected={nttc_toggle_jobs}
              icon="user-tag"
              onClick={() => act('nttc_toggle_jobs')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Job Departmentalisation">
            <Button
              content={nttc_toggle_job_color ? 'On' : 'Off'}
              selected={nttc_toggle_job_color}
              icon="clipboard-list"
              onClick={() => act('nttc_toggle_job_color')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Name Departmentalisation">
            <Button
              content={nttc_toggle_name_color ? 'On' : 'Off'}
              selected={nttc_toggle_name_color}
              icon="user-tag"
              onClick={() => act('nttc_toggle_name_color')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Command Amplification">
            <Button
              content={nttc_toggle_command_bold ? 'On' : 'Off'}
              selected={nttc_toggle_command_bold}
              icon="volume-up"
              onClick={() => act('nttc_toggle_command_bold')}
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>

      <Section title="Advanced">
        <LabeledList>
          <LabeledList.Item label="Job Announcement Format">
            <Button
              content={nttc_job_indicator_type ? nttc_job_indicator_type : 'Unset'}
              selected={nttc_job_indicator_type}
              icon="pencil-alt"
              onClick={() => act('nttc_job_indicator_type')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Language Conversion">
            <Button
              content={nttc_setting_language ? nttc_setting_language : 'Unset'}
              selected={nttc_setting_language}
              icon="globe"
              onClick={() => act('nttc_setting_language')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Network ID">
            <Button
              content={network_id ? network_id : 'Unset'}
              selected={network_id}
              icon="server"
              onClick={() => act('network_id')}
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>

      <Section title="Maintenance">
        <Button content="Import Configuration" icon="file-import" onClick={() => act('import')} />
        <Button content="Export Configuration" icon="file-export" onClick={() => act('export')} />
      </Section>
    </>
  );
};

const LinkagePage = (_properties) => {
  const { act, data } = useBackend();
  const { link_password, relay_entries } = data;
  return (
    <Section title="Device Linkage">
      <LabeledList>
        <LabeledList.Item label="Linkage Password">
          <Button
            content={link_password ? link_password : 'Unset'}
            selected={link_password}
            icon="lock"
            onClick={() => act('change_password')}
          />
        </LabeledList.Item>
      </LabeledList>

      <Table m="0.5rem">
        <Table.Row header>
          <Table.Cell>Network Address</Table.Cell>
          <Table.Cell>Network ID</Table.Cell>
          <Table.Cell>Sector</Table.Cell>
          <Table.Cell>Status</Table.Cell>
          <Table.Cell>Unlink</Table.Cell>
        </Table.Row>
        {relay_entries.map((r) => (
          <Table.Row key={r.addr}>
            <Table.Cell>{r.addr}</Table.Cell>
            <Table.Cell>{r.net_id}</Table.Cell>
            <Table.Cell>{r.sector}</Table.Cell>
            <Table.Cell>{r.status === 1 ? <Box color="green">Online</Box> : <Box color="red">Offline</Box>}</Table.Cell>
            <Table.Cell>
              <Button
                content="Unlink"
                icon="unlink"
                onClick={() =>
                  act('unlink', {
                    addr: r.addr,
                  })
                }
              />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const FilteringPage = (_properties) => {
  const { act, data } = useBackend();
  const { filtered_users } = data;
  return (
    <Section
      title="User Filtering"
      buttons={<Button content="Add User" icon="user-plus" onClick={() => act('add_filter')} />}
    >
      <Table m="0.5rem">
        <Table.Row header>
          <Table.Cell style={{ width: '90%' }}>User</Table.Cell>
          <Table.Cell style={{ width: '10%' }}>Actions</Table.Cell>
        </Table.Row>
        {filtered_users.map((u) => (
          <Table.Row key={u}>
            <Table.Cell>{u}</Table.Cell>
            <Table.Cell>
              <Button
                content="Remove"
                icon="user-times"
                onClick={() =>
                  act('remove_filter', {
                    user: u,
                  })
                }
              />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
