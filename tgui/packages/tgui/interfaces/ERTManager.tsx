import { useState } from 'react';
import { Box, Button, Icon, LabeledList, Section, Stack, Tabs, TextArea } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';
import { decodeHtmlEntities } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const PickTab = (index: number) => {
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

export const ERTManager = () => {
  const [tabIndex, setTabIndex] = useState(0);

  return (
    <Window width={360} height={510}>
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

type ERTRequestMessage = {
  time: string;
  sender_real_name: string;
  sender_uid: string;
  message: string;
};

type ERTManagerData = {
  security_level_color: string;
  str_security_level: string;
  ert_request_answered: BooleanLike;
  ert_type: string;
  com: number;
  sec: number;
  med: number;
  eng: number;
  jan: number;
  par: number;
  cyb: number;
  secborg: number;
  total: number;
  spawnpoints: number;
  ert_request_messages: ERTRequestMessage[];
};

export const ERTOverview = () => {
  const { act, data } = useBackend<ERTManagerData>();
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
              onClick={() => act('toggle_ert_request_answered')}
              tooltip={'Checking this box will disable the next ERT reminder notification'}
              selected={null}
            >
              {ert_request_answered ? 'Answered' : 'Unanswered'}
            </Button.Checkbox>
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Stack.Item>
  );
};

const SendERT = () => {
  const { act, data } = useBackend<ERTManagerData>();
  const { ert_type, com, sec, med, eng, par, jan, cyb, secborg, total, spawnpoints } = data;
  let slotOptions = [0, 1, 2, 3, 4, 5];

  const [silentERT, setSilentERT] = useState(false);

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
              textAlign="center"
              color={ert_type === 'Amber' ? 'orange' : ''}
              onClick={() => act('ert_type', { ert_type: 'Amber' })}
            >
              Amber
            </Button>
            <Button
              width={5}
              textAlign="center"
              color={ert_type === 'Red' ? 'red' : ''}
              onClick={() => act('ert_type', { ert_type: 'Red' })}
            >
              Red
            </Button>
            <Button
              width={5}
              textAlign="center"
              color={ert_type === 'Gamma' ? 'purple' : ''}
              onClick={() => act('ert_type', { ert_type: 'Gamma' })}
            >
              Gamma
            </Button>
          </>
        }
      >
        <LabeledList>
          <LabeledList.Item label="Commander">
            <Button icon={com ? 'toggle-on' : 'toggle-off'} selected={com} onClick={() => act('toggle_com')}>
              {com ? 'Yes' : 'No'}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Security">
            {slotOptions.map((a, i) => (
              <Button
                key={'sec' + a}
                selected={sec === a}
                onClick={() =>
                  act('set_sec', {
                    set_sec: a,
                  })
                }
              >
                {String(a)}
              </Button>
            ))}
          </LabeledList.Item>
          <LabeledList.Item label="Medical">
            {slotOptions.map((a, i) => (
              <Button
                key={'med' + a}
                selected={med === a}
                onClick={() =>
                  act('set_med', {
                    set_med: a,
                  })
                }
              >
                {String(a)}
              </Button>
            ))}
          </LabeledList.Item>
          <LabeledList.Item label="Engineering">
            {slotOptions.map((a, i) => (
              <Button
                key={'eng' + a}
                selected={eng === a}
                onClick={() =>
                  act('set_eng', {
                    set_eng: a,
                  })
                }
              >
                {String(a)}
              </Button>
            ))}
          </LabeledList.Item>
          <LabeledList.Item label="Paranormal">
            {slotOptions.map((a, i) => (
              <Button
                key={'par' + a}
                selected={par === a}
                onClick={() =>
                  act('set_par', {
                    set_par: a,
                  })
                }
              >
                {String(a)}
              </Button>
            ))}
          </LabeledList.Item>
          <LabeledList.Item label="Janitor">
            {slotOptions.map((a, i) => (
              <Button
                key={'jan' + a}
                selected={jan === a}
                onClick={() =>
                  act('set_jan', {
                    set_jan: a,
                  })
                }
              >
                {String(a)}
              </Button>
            ))}
          </LabeledList.Item>
          <LabeledList.Item label="Cyborg">
            {slotOptions.map((a, i) => (
              <Button
                key={'cyb' + a}
                selected={cyb === a}
                onClick={() =>
                  act('set_cyb', {
                    set_cyb: a,
                  })
                }
              >
                {String(a)}
              </Button>
            ))}
          </LabeledList.Item>
          <LabeledList.Item label="Security Module">
            <Button
              width={10.5}
              disabled={ert_type !== 'Red' || !cyb}
              icon={secborg ? 'toggle-on' : 'toggle-off'}
              color={secborg ? 'red' : ''}
              textAlign="center"
              onClick={() => act('toggle_secborg')}
            >
              {secborg ? 'Enabled' : ert_type !== 'Red' ? 'Unavailable' : 'Disabled'}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Silent ERT">
            <Button
              width={10.5}
              icon={silentERT ? 'microphone-slash' : 'microphone'}
              textAlign="center"
              selected={silentERT}
              onClick={() => setSilentERT(!silentERT)}
              tooltip={
                silentERT
                  ? 'This ERT will not be announced to the station'
                  : 'This ERT will be announced to the station on dispatch'
              }
              tooltipPosition="top"
            >
              {silentERT ? 'Silenced' : 'Public'}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Total Slots">
            <Box color={total > spawnpoints ? 'red' : 'green'}>
              {total} total, versus {spawnpoints} spawnpoints
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Dispatch">
            <Button
              width={10.5}
              textAlign="center"
              icon="ambulance"
              onClick={() => act('dispatch_ert', { silent: silentERT })}
            >
              Send ERT
            </Button>
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Stack.Item>
  );
};

const ReadERTRequests = () => {
  const { act, data } = useBackend<ERTManagerData>();

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
                  onClick={() => act('view_player_panel', { uid: request.sender_uid })}
                  tooltip="View player panel"
                >
                  {request.sender_real_name}
                </Button>
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

const DenyERT = () => {
  const { act } = useBackend();

  const [text, setText] = useState('');

  return (
    <Stack.Item grow>
      <Section fill>
        <TextArea
          placeholder="Enter ERT denial reason here. Shift-Enter to add a new line."
          fluid
          height={24}
          value={text}
          onChange={(value) => setText(value)}
        />
        <Button.Confirm fluid icon="times" mt={2} textAlign="center" onClick={() => act('deny_ert', { reason: text })}>
          Deny ERT
        </Button.Confirm>
      </Section>
    </Stack.Item>
  );
};
