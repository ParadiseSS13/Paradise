import { Fragment } from "inferno";
import { useBackend } from "../backend";
import { Box, Button, LabeledList, Section, Tabs } from "../components";
import { Window } from "../layouts";
import { AccessList } from './common/AccessList';

export const GuestPass = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            icon="id-card"
            selected={!data.showlogs}
            onClick={() => act("mode", { mode: 0 })} >
            Issue Pass
          </Tabs.Tab>
          <Tabs.Tab
            icon="scroll"
            selected={data.showlogs}
            onClick={() => act("mode", { mode: 1 })}>
            Records ({data.issue_log.length})
          </Tabs.Tab>
        </Tabs>
        <Section title="Authorization">
          <LabeledList>
            <LabeledList.Item label="ID Card">
              <Button
                icon={data.scan_name ? 'eject' : 'id-card'}
                selected={data.scan_name}
                content={data.scan_name ? data.scan_name : '-----'}
                tooltip={data.scan_name ? "Eject ID" : "Insert ID"}
                onClick={() => act("scan")} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {!data.showlogs && (
          <Section title="Issue Guest Pass">
            <LabeledList>
              <LabeledList.Item label="Issue To">
                <Button
                  icon="pencil-alt"
                  content={data.giv_name ? data.giv_name : "-----"}
                  disabled={!data.scan_name}
                  onClick={() => act("giv_name")} />
              </LabeledList.Item>
              <LabeledList.Item label="Reason">
                <Button
                  icon="pencil-alt"
                  content={data.reason ? data.reason : "-----"}
                  disabled={!data.scan_name}
                  onClick={() => act("reason")} />
              </LabeledList.Item>
              <LabeledList.Item label="Duration">
                <Button
                  icon="pencil-alt"
                  content={data.duration ? data.duration : "-----"}
                  disabled={!data.scan_name}
                  onClick={() => act("duration")} />
              </LabeledList.Item>
            </LabeledList>
            {!!data.scan_name && (
              <Fragment>
                <AccessList
                  grantableList={data.grantableList}
                  accesses={data.regions}
                  selectedList={data.selectedAccess}
                  accessMod={ref => act('access', {
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
                <Button
                  icon="id-card"
                  content={data.printmsg}
                  disabled={!data.canprint}
                  onClick={() => act("issue")} />
              </Fragment>
            )}
          </Section>
        )}
        {!!data.showlogs && (
          <Section title="Issuance Log">
            {!!data.issue_log.length && (
              <Fragment>
                <LabeledList>
                  {data.issue_log.map((a, i) => (
                    <LabeledList.Item key={i}>
                      {a}
                    </LabeledList.Item>
                  ))}
                </LabeledList>
                <Button
                  icon="print"
                  content={"Print"}
                  disabled={!data.scan_name}
                  onClick={() => act("print")} />
              </Fragment>
            ) || (
              <Box>
                None.
              </Box>
            )}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
