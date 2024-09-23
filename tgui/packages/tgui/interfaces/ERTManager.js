import { useBackend, useLocalState } from '../backend';
import { Button, LabeledList, Box, Section, Stack, Tabs, Input, Icon } from '../components';
import { Window } from '../layouts';
import { decodeHtmlEntities } from 'common/string';

const PickTab = (index) => {
  switch (index) {
    case 0:
      return <SendERT />;
    case 1:
      return <ReadERTRequests />;
    case 2:
      return <DenyERT />;
    default:
      return "SOMETHING WENT VERY WRONG PLEASE AHELP, WAIT YOU'RE AN ADMIN, OH FUUUUCK! call a coder or something";
  }
};

export const ERTManager = (props, context) => {
  const { act, data } = useBackend(context);

  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);

  return (
    <Window width={360} height={505}>
      <Window.Content>
        <Stack fill vertical>
          <ERTOverview />
          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab
                key="SendERT"
                selected={tabIndex === 0}
                onClick={() => {
                  setTabIndex(0);
                }}
                icon="ambulance"
              >
                Send ERT
              </Tabs.Tab>
              <Tabs.Tab
                key="ReadERTRequests"
                selected={tabIndex === 1}
                onClick={() => {
                  setTabIndex(1);
                }}
                icon="book"
              >
                Read ERT Requests
              </Tabs.Tab>
              <Tabs.Tab
                key="DenyERT"
                selected={tabIndex === 2}
                onClick={() => {
                  setTabIndex(2);
                }}
                icon="times"
              >
                Deny ERT
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          {PickTab(tabIndex)}
        </Stack>
      </Window.Content>
    </Window>
  );
};

export const ERTOverview = (props, context) => {
  const { act, data } = useBackend(context);
  const { security_level_color, str_security_level, ert_request_answered } = data;

  return (
    <Stack.Item>
      <Section title="Overview">
        <LabeledList>
          <LabeledList.Item label="Current Alert" color={security_level_color}>
            {str_security_level}
          </LabeledList.Item>
          <LabeledList.Item label="ERT Request">
            <Button.Checkbox
              checked={ert_request_answered}
              textColor={ert_request_answered ? null : 'bad'}
              content={ert_request_answered ? 'Answered' : 'Unanswered'}
              onClick={() => act('toggle_ert_request_answered')}
              tooltip={'Checking this box will disable the next ERT reminder notification'}
              selected={null}
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Stack.Item>
  );
};

const SendERT = (props, context) => {
  const { act, data } = useBackend(context);
  let slotOptions = [0, 1, 2, 3, 4, 5];

  const [silentERT, setSilentERT] = useLocalState(context, 'silentERT', false);

  return (
    <Stack.Item grow>
      <Section
        fill
        scrollable
        title="Send ERT"
        buttons={
          <>
            <Button
              width={5}
              content="Amber"
              textAlign="center"
              color={data.ert_type === 'Amber' ? 'orange' : ''}
              onClick={() => act('ert_type', { ert_type: 'Amber' })}
            />
            <Button
              width={5}
              content="Red"
              textAlign="center"
              color={data.ert_type === 'Red' ? 'red' : ''}
              onClick={() => act('ert_type', { ert_type: 'Red' })}
            />
            <Button
              width={5}
              content="Gamma"
              textAlign="center"
              color={data.ert_type === 'Gamma' ? 'purple' : ''}
              onClick={() => act('ert_type', { ert_type: 'Gamma' })}
            />
          </>
        }
      >
        <LabeledList>
          <LabeledList.Item label="Commander">
            <Button
              icon={data.com ? 'toggle-on' : 'toggle-off'}
              selected={data.com}
              content={data.com ? 'Yes' : 'No'}
              onClick={() => act('toggle_com')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Security">
            {slotOptions.map((a, i) => (
              <Button
                key={'sec' + a}
                selected={data.sec === a}
                content={a}
                onClick={() =>
                  act('set_sec', {
                    set_sec: a,
                  })
                }
              />
            ))}
          </LabeledList.Item>
          <LabeledList.Item label="Medical">
            {slotOptions.map((a, i) => (
              <Button
                key={'med' + a}
                selected={data.med === a}
                content={a}
                onClick={() =>
                  act('set_med', {
                    set_med: a,
                  })
                }
              />
            ))}
          </LabeledList.Item>
          <LabeledList.Item label="Engineering">
            {slotOptions.map((a, i) => (
              <Button
                key={'eng' + a}
                selected={data.eng === a}
                content={a}
                onClick={() =>
                  act('set_eng', {
                    set_eng: a,
                  })
                }
              />
            ))}
          </LabeledList.Item>
          <LabeledList.Item label="Paranormal">
            {slotOptions.map((a, i) => (
              <Button
                key={'par' + a}
                selected={data.par === a}
                content={a}
                onClick={() =>
                  act('set_par', {
                    set_par: a,
                  })
                }
              />
            ))}
          </LabeledList.Item>
          <LabeledList.Item label="Janitor">
            {slotOptions.map((a, i) => (
              <Button
                key={'jan' + a}
                selected={data.jan === a}
                content={a}
                onClick={() =>
                  act('set_jan', {
                    set_jan: a,
                  })
                }
              />
            ))}
          </LabeledList.Item>
          <LabeledList.Item label="Cyborg">
            {slotOptions.map((a, i) => (
              <Button
                key={'cyb' + a}
                selected={data.cyb === a}
                content={a}
                onClick={() =>
                  act('set_cyb', {
                    set_cyb: a,
                  })
                }
              />
            ))}
          </LabeledList.Item>
          <LabeledList.Item label="Security Module">
            <Button
              width={10.5}
              disabled={data.ert_type !== 'Red' || !data.cyb}
              icon={data.secborg ? 'toggle-on' : 'toggle-off'}
              color={data.secborg ? 'red' : ''}
              content={data.secborg ? 'Enabled' : data.ert_type !== 'Red' ? 'Unavailable' : 'Disabled'}
              textAlign="center"
              onClick={() => act('toggle_secborg')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Silent ERT">
            <Button
              width={10.5}
              icon={silentERT ? 'microphone-slash' : 'microphone'}
              content={silentERT ? 'Silenced' : 'Public'}
              textAlign="center"
              selected={silentERT}
              onClick={() => setSilentERT(!silentERT)}
              tooltip={
                silentERT
                  ? 'This ERT will not be announced to the station'
                  : 'This ERT will be announced to the station on dispatch'
              }
              tooltipPosition="top"
            />
          </LabeledList.Item>
          <LabeledList.Item label="Total Slots">
            <Box color={data.total > data.spawnpoints ? 'red' : 'green'}>
              {data.total} total, versus {data.spawnpoints} spawnpoints
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Dispatch">
            <Button
              width={10.5}
              textAlign="center"
              icon="ambulance"
              content="Send ERT"
              onClick={() => act('dispatch_ert', { silent: silentERT })}
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Stack.Item>
  );
};

const ReadERTRequests = (props, context) => {
  const { act, data } = useBackend(context);

  const { ert_request_messages } = data;

  return (
    <Stack.Item grow>
      <Section fill>
        {ert_request_messages && ert_request_messages.length ? (
          ert_request_messages.map((request) => (
            <Section
              key={decodeHtmlEntities(request.time)}
              title={request.time}
              buttons={
                <Button
                  content={request.sender_real_name}
                  onClick={() => act('view_player_panel', { uid: request.sender_uid })}
                  tooltip="View player panel"
                />
              }
            >
              {request.message}
            </Section>
          ))
        ) : (
          <Stack fill>
            <Stack.Item bold grow textAlign="center" align="center" color="average">
              <Icon.Stack>
                <Icon name="broadcast-tower" size={5} color="gray" />
                <Icon name="slash" size={5} color="red" />
              </Icon.Stack>
              <br />
              No ERT requests.
            </Stack.Item>
          </Stack>
        )}
      </Section>
    </Stack.Item>
  );
};

const DenyERT = (props, context) => {
  const { act, data } = useBackend(context);

  const [text, setText] = useLocalState(context, 'text', '');

  return (
    <Stack.Item grow>
      <Section fill>
        <Input
          placeholder="Enter ERT denial reason here,\nMultiline input is accepted."
          rows={19}
          fluid
          multiline={1}
          value={text}
          onChange={(e, value) => setText(value)}
        />
        <Button.Confirm
          content="Deny ERT"
          fluid
          icon="times"
          center
          mt={2}
          textAlign="center"
          onClick={() => act('deny_ert', { reason: text })}
        />
      </Section>
    </Stack.Item>
  );
};
