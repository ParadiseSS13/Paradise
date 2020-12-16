import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, LabeledList, Box, Section, Table, Tabs } from '../components';
import { Window } from '../layouts';
import { AccessList } from './common/AccessList';

export const CardComputer = (props, context) => {
  const { act, data } = useBackend(context);


  let menuBlock = (
    <Tabs>
      <Tabs.Tab
        icon="id-card"
        selected={data.mode === 0}
        onClick={() => act("mode", { mode: 0 })} >
        Job Transfers
      </Tabs.Tab>
      {!data.target_dept && (
        <Tabs.Tab
          icon="id-card"
          selected={data.mode === 2}
          onClick={() => act("mode", { mode: 2 })} >
          Access Modification
        </Tabs.Tab>
      )}
      <Tabs.Tab
        icon="folder-open"
        selected={data.mode === 1}
        onClick={() => act("mode", { mode: 1 })}>
        Job Management
      </Tabs.Tab>
      <Tabs.Tab
        icon="scroll"
        selected={data.mode === 3}
        onClick={() => act("mode", { mode: 3 })}>
        Records
      </Tabs.Tab>
      <Tabs.Tab
        icon="users"
        selected={data.mode === 4}
        onClick={() => act("mode", { mode: 4 })}>
        Department
      </Tabs.Tab>
    </Tabs>
  );


  let authBlock = (
    <Section title="Authentication">
      <LabeledList>
        <LabeledList.Item label="Login/Logout">
          <Button
            icon={data.scan_name ? 'sign-out-alt' : 'id-card'}
            selected={data.scan_name}
            content={data.scan_name
              ? "Log Out: " + data.scan_name
              : "-----"}
            onClick={() => act("scan")} />
        </LabeledList.Item>
        <LabeledList.Item label="Card To Modify">
          <Button
            icon={data.modify_name ? 'eject' : 'id-card'}
            selected={data.modify_name}
            content={data.modify_name
              ? "Remove Card: " + data.modify_name
              : "-----"}
            onClick={() => act("modify")} />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );

  let bodyBlock;

  switch (data.mode) {
    case 0: // job transfer
      if (!data.authenticated || !data.scan_name) {
        bodyBlock = (
          <Section title="Warning" color="red">
            Not logged in.
          </Section>
        );
      } else if (!data.modify_name) {
        bodyBlock = (
          <Section title="Card Missing" color="red">
            No card to modify.
          </Section>
        );
      } else if (data.target_dept) {
        bodyBlock = (
          <Section title="Department Job Transfer">
            <LabeledList>
              {!!data.modify_lastlog && (
                <LabeledList.Item label="Latest Transfer">
                  {data.modify_lastlog}
                </LabeledList.Item>
              )}
              <LabeledList.Item label="Department">
                {data.jobs_dept.map(v => (
                  <Button
                    selected={v === data.modify_rank}
                    key={v} content={v}
                    onClick={() => act("assign", { assign_target: v })} />
                ))}
              </LabeledList.Item>
              <LabeledList.Item label="Retirement">
                <Button
                  selected={"Civilian" === data.modify_rank}
                  key="Civilian" content="Civilian"
                  onClick={() => act("assign",
                    { assign_target: "Civilian" })} />
              </LabeledList.Item>
              <LabeledList.Item label="Demotion">
                <Button
                  selected={"Demoted" === data.modify_rank}
                  key="Demoted" content="Demoted"
                  tooltip="Civilian access, 'demoted' title."
                  color="red" icon="times"
                  onClick={() => act("demote")} />
              </LabeledList.Item>
              {!!data.canterminate && (
                <LabeledList.Item label="Non-Crew">
                  <Button
                    disabled={"Terminated" === data.modify_rank}
                    key="Terminate" content="Terminated"
                    tooltip="Zero access. Not crew."
                    color="red" icon="eraser"
                    onClick={() => act("terminate")} />
                </LabeledList.Item>
              )}
            </LabeledList>
          </Section>
        );
      } else {
        bodyBlock = (
          <Fragment>
            <Section title="Card Information">
              <LabeledList.Item label="Registered Name">
                <Button
                  icon={!data.modify_owner || data.modify_owner === "Unknown"
                    ? "exclamation-triangle"
                    : "pencil-alt"}
                  selected={data.modify_name}
                  content={data.modify_owner}
                  onClick={() => act("reg")} />
              </LabeledList.Item>
              <LabeledList.Item label="Account Number">
                <Button
                  icon={data.account_number
                    ? "pencil-alt"
                    : "exclamation-triangle"}
                  selected={data.account_number}
                  content={data.account_number
                    ? data.account_number
                    : "None"}
                  onClick={() => act("account")} />
              </LabeledList.Item>
              {!!data.modify_lastlog && (
                <LabeledList.Item label="Latest Transfer">
                  {data.modify_lastlog}
                </LabeledList.Item>
              )}

            </Section>
            <Section title="Job Transfer">
              <LabeledList>
                <LabeledList.Item label="Special">
                  {data.jobs_top.map(v => (
                    <Button
                      selected={v === data.modify_rank}
                      key={v} content={v}
                      color={data.jobFormats[v] ? data.jobFormats[v] : ""}
                      onClick={() => act("assign", { assign_target: v })} />
                  ))}
                </LabeledList.Item>
                <LabeledList.Item label="Engineering">
                  {data.jobs_engineering.map(v => (
                    <Button
                      key={v} content={v}
                      color={data.jobFormats[v] ? data.jobFormats[v] : ""}
                      onClick={() => act("assign", { assign_target: v })} />
                  ))}
                </LabeledList.Item>
                <LabeledList.Item label="Medical">
                  {data.jobs_medical.map(v => (
                    <Button
                      key={v} content={v}
                      color={data.jobFormats[v] ? data.jobFormats[v] : ""}
                      onClick={() => act("assign", { assign_target: v })} />
                  ))}
                </LabeledList.Item>
                <LabeledList.Item label="Science">
                  {data.jobs_science.map(v => (
                    <Button
                      key={v} content={v}
                      color={data.jobFormats[v] ? data.jobFormats[v] : ""}
                      onClick={() => act("assign", { assign_target: v })} />
                  ))}
                </LabeledList.Item>
                <LabeledList.Item label="Security">
                  {data.jobs_security.map(v => (
                    <Button
                      selected={v === data.modify_rank}
                      key={v} content={v}
                      color={data.jobFormats[v] ? data.jobFormats[v] : ""}
                      onClick={() => act("assign", { assign_target: v })} />
                  ))}
                </LabeledList.Item>
                <LabeledList.Item label="Service">
                  {data.jobs_service.map(v => (
                    <Button
                      selected={v === data.modify_rank}
                      key={v} content={v}
                      color={data.jobFormats[v] ? data.jobFormats[v] : ""}
                      onClick={() => act("assign", { assign_target: v })} />
                  ))}
                </LabeledList.Item>
                <LabeledList.Item label="Supply">
                  {data.jobs_supply.map(v => (
                    <Button
                      selected={v === data.modify_rank}
                      key={v} content={v}
                      color={data.jobFormats[v] ? data.jobFormats[v] : ""}
                      onClick={() => act("assign", { assign_target: v })} />
                  ))}
                </LabeledList.Item>
                <LabeledList.Item label="Civilan">
                  {data.jobs_civilian.map(v => (
                    <Button
                      selected={v === data.modify_rank}
                      key={v} content={v}
                      color={data.jobFormats[v] ? data.jobFormats[v] : ""}
                      onClick={() => act("assign", { assign_target: v })} />
                  ))}
                </LabeledList.Item>
                <LabeledList.Item label="Restricted">
                  {data.jobs_karma.map(v => (
                    <Button
                      selected={v === data.modify_rank}
                      color={data.jobFormats[v] ? data.jobFormats[v] : ""}
                      key={v} content={v}
                      onClick={() => act("assign", { assign_target: v })} />
                  ))}
                </LabeledList.Item>
                {!!data.iscentcom && (
                  <LabeledList.Item label="CentCom">
                    {data.jobs_centcom.map(v => (
                      <Button
                        selected={v === data.modify_rank}
                        color={data.jobFormats[v]
                          ? data.jobFormats[v]
                          : "purple"}
                        key={v} content={v}
                        onClick={() => act("assign", { assign_target: v })} />
                    ))}
                  </LabeledList.Item>
                )}
                <LabeledList.Item label="Demotions">
                  <Button
                    disabled={"Terminated" === data.modify_rank}
                    key="Demoted" content="Demoted"
                    selected={"Demoted" === data.modify_rank}
                    tooltip="Civilian access, 'demoted' title."
                    color="red" icon="times"
                    onClick={() => act("demote")} />
                </LabeledList.Item>
                <LabeledList.Item label="Non-Crew">
                  <Button
                    disabled={"Terminated" === data.modify_rank}
                    key="Terminate" content="Terminated"
                    tooltip="Zero access. Not crew."
                    color="red" icon="eraser"
                    onClick={() => act("terminate")} />
                </LabeledList.Item>
              </LabeledList>

            </Section>
            <Section title="Card Skins">
              {data.card_skins.map(v => (
                <Button
                  selected={v.skin === data.current_skin}
                  key={v.skin} content={v.display_name}
                  onClick={() => act("skin", { skin_target: v.skin })} />
              ))}
              {!!data.iscentcom && (
                <Box>
                  {data.all_centcom_skins.map(v => (
                    <Button
                      selected={v.skin === data.current_skin}
                      key={v.skin} content={v.display_name} color="purple"
                      onClick={() => act("skin", { skin_target: v.skin })} />
                  ))}
                </Box>
              )}
            </Section>
          </Fragment>
        );
      }
      break;
    case 1: // job slot management
      if (!data.authenticated || !data.scan_name) {
        bodyBlock = (
          <Section title="Warning" color="red">
            Not logged in.
          </Section>
        );
      } else {
        bodyBlock = (
          <Fragment>
            <Section color={data.cooldown_time ? "red" : ""}>
              Next Change Available:
              {data.cooldown_time ? data.cooldown_time : "Now"}
            </Section>
            <Section title="Job Slots">


              <Table>
                <Table.Row>
                  <Table.Cell bold textAlign="center">Title</Table.Cell>
                  <Table.Cell bold textAlign="center">Used Slots</Table.Cell>
                  <Table.Cell bold textAlign="center">Total Slots</Table.Cell>
                  <Table.Cell bold textAlign="center">Free Slots</Table.Cell>
                  <Table.Cell bold textAlign="center">Close Slot</Table.Cell>
                  <Table.Cell bold textAlign="center">Open Slot</Table.Cell>
                  <Table.Cell bold textAlign="center">Priority</Table.Cell>
                </Table.Row>
                {data.job_slots.map(slotData => (
                  <Table.Row key={slotData.title}>
                    <Table.Cell textAlign="center">
                      {slotData.title}
                    </Table.Cell>
                    <Table.Cell textAlign="center">
                      {slotData.current_positions}
                    </Table.Cell>
                    <Table.Cell textAlign="center">
                      {slotData.total_positions}
                    </Table.Cell>
                    <Table.Cell textAlign="center">
                      {slotData.total_positions
                        > slotData.current_positions && (
                        <Box color="green">
                          {slotData.total_positions
                          - slotData.current_positions}
                        </Box>
                      ) || (
                        <Box color="red">
                          0
                        </Box>
                      )}
                    </Table.Cell>
                    <Table.Cell textAlign="center">
                      <Button
                        content="-"
                        disabled={data.cooldown_time || !slotData.can_close}
                        onClick={() => act("make_job_unavailable",
                          { job: slotData.title })} />
                    </Table.Cell>
                    <Table.Cell textAlign="center">
                      <Button
                        content="+"
                        disabled={data.cooldown_time || !slotData.can_open}
                        onClick={() => act("make_job_available",
                          { job: slotData.title })} />
                    </Table.Cell>
                    <Table.Cell textAlign="center">
                      {data.target_dept && (
                        <Box color="green">
                          {data.priority_jobs.indexOf(slotData.title) > -1
                            ? "Yes"
                            : ""}
                        </Box>
                      ) || (
                        <Button
                          content="Priority"
                          selected={
                            data.priority_jobs.indexOf(slotData.title) > -1
                          }
                          disabled={
                            data.cooldown_time || !slotData.can_prioritize
                          }
                          onClick={() => act("prioritize_job",
                            { job: slotData.title })} />
                      )}
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Section>
          </Fragment>
        );
      }
      break;
    case 2: // access change
      if (!data.authenticated || !data.scan_name) {
        bodyBlock = (
          <Section title="Warning" color="red">
            Not logged in.
          </Section>
        );
      } else if (!data.modify_name) {
        bodyBlock = (
          <Section title="Card Missing" color="red">
            No card to modify.
          </Section>
        );
      } else {
        bodyBlock = (
          <AccessList
            accesses={data.regions}
            selectedList={data.selectedAccess}
            accessMod={ref => act('set', {
              access: ref,
            })}
            grantAll={() => act('grant_all')}
            denyAll={() => act('clear_all')}
            grantDep={ref => act('grant_region', {
              region: ref,
            })}
            denyDep={ref => act('deny_region', {
              region: ref,
            })} />
        );
      }
      break;
    case 3: // records
      if (!data.authenticated) {
        bodyBlock = (
          <Section title="Warning" color="red">
            Not logged in.
          </Section>
        );
      } else if (!data.records.length) {
        bodyBlock = (
          <Section title="Records">
            No records.
          </Section>
        );
      } else {
        bodyBlock = (
          <Section title="Records" buttons={
            <Button
              icon="times"
              content="Delete All Records"
              disabled={!data.authenticated
                || data.records.length === 0
                || data.target_dept}
              onClick={() => act('wipe_all_logs')} />
          }>
            <Table>
              <Table.Row>
                <Table.Cell bold>Crewman</Table.Cell>
                <Table.Cell bold>Old Rank</Table.Cell>
                <Table.Cell bold>New Rank</Table.Cell>
                <Table.Cell bold>Authorized By</Table.Cell>
                <Table.Cell bold>Time</Table.Cell>
                <Table.Cell bold>Reason</Table.Cell>
                {!!data.iscentcom && (
                  <Table.Cell bold>
                    Deleted By
                  </Table.Cell>
                )}
              </Table.Row>
              {data.records.map(record => (
                <Table.Row key={record.timestamp}>
                  <Table.Cell>{record.transferee}</Table.Cell>
                  <Table.Cell>{record.oldvalue}</Table.Cell>
                  <Table.Cell>{record.newvalue}</Table.Cell>
                  <Table.Cell>{record.whodidit}</Table.Cell>
                  <Table.Cell>{record.timestamp}</Table.Cell>
                  <Table.Cell>{record.reason}</Table.Cell>
                  {!!data.iscentcom && (
                    <Table.Cell>
                      {record.deletedby}
                    </Table.Cell>
                  )}
                </Table.Row>
              ))}
            </Table>
            {!!data.iscentcom && (
              <Box>
                <Button
                  icon="pencil-alt"
                  content="Delete MY Records"
                  color="purple"
                  disabled={!data.authenticated
                    || data.records.length === 0}
                  onClick={() => act('wipe_my_logs')} />
              </Box>
            )}
          </Section>
        );
      }
      break;
    case 4: // department
      if (!data.authenticated || !data.scan_name) {
        bodyBlock = (
          <Section title="Warning" color="red">
            Not logged in.
          </Section>
        );
      } else {
        bodyBlock = (
          <Section title="Your Team">
            <Table>
              <Table.Row>
                <Table.Cell bold>Name</Table.Cell>
                <Table.Cell bold>Rank</Table.Cell>
                <Table.Cell bold>Sec Status</Table.Cell>
                <Table.Cell bold>Actions</Table.Cell>
              </Table.Row>
              {data.people_dept.map(record => (
                <Table.Row key={record.title}>
                  <Table.Cell>{record.name}</Table.Cell>
                  <Table.Cell>{record.title}</Table.Cell>
                  <Table.Cell>{record.crimstat}</Table.Cell>
                  <Table.Cell>
                    <Button
                      content={record.buttontext}
                      disabled={!record.demotable}
                      onClick={() => act("remote_demote",
                        { remote_demote: record.name })} />
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
        );
      }
      break;
    default:
      bodyBlock = (
        <Section title="Warning" color="red">
          ERROR: Unknown Mode.
        </Section>
      );
  }

  return (
    <Window resizable>
      <Window.Content scrollable>
        {menuBlock}
        {authBlock}
        {bodyBlock}
      </Window.Content>
    </Window>
  );

};
