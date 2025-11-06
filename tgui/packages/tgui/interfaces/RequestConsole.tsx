import { Blink, Box, Button, LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { BooleanLike } from 'tgui-core/react';

enum MsgPriority {
  RQ_NONEW_MESSAGES = 0,
  RQ_LOWPRIORITY = 1,
  RQ_NORMALPRIORITY = 2,
  RQ_HIGHPRIORITY = 3,
}

type RequestConsoleData = {
  announceAuth: BooleanLike;
  announcementConsole: BooleanLike;
  assist_dept: string[];
  department: string;
  info_dept: string[];
  message_log: string[][];
  message: string;
  msgStamped: string;
  msgVerified: string;
  newmessagepriority: MsgPriority;
  recipient: string;
  screen: BooleanLike;
  secondaryGoalAuth: BooleanLike;
  secondaryGoalEnabled: BooleanLike;
  ship_dept: string[];
  shipDest: string;
  shipping_log: string[][];
  silent: BooleanLike;
  supply_dept: string[];
};

export const RequestConsole = () => {
  const { data } = useBackend<RequestConsoleData>();
  const { screen, announcementConsole } = data;

  const pickPage = (index) => {
    switch (index) {
      case 0:
        return <MainMenu />;
      case 1:
        return <DepartmentList purpose="ASSISTANCE" />;
      case 2:
        return <DepartmentList purpose="SUPPLIES" />;
      case 3:
        return <DepartmentList purpose="INFO" />;
      case 4:
        return <MessageResponse type="SUCCESS" />;
      case 5:
        return <MessageResponse type="FAIL" />;
      case 6:
        return <MessageLog type="MESSAGES" />;
      case 7:
        return <MessageAuth />;
      case 8:
        return <StationAnnouncement />;
      case 9:
        return <PrintShippingLabel />;
      case 10:
        return <MessageLog type="SHIPPING" />;
      case 11:
        return <SecondaryGoal />;
      default:
        return "WE SHOULDN'T BE HERE!";
    }
  };

  return (
    <Window width={450} height={announcementConsole ? 430 : 385}>
      <Window.Content scrollable>
        <Stack fill vertical>
          {pickPage(screen)}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MainMenuButton = (props: { text: string; icon: string; screen: number }) => {
  const { act } = useBackend();
  const { text, icon, screen } = props;
  return (
    <Button fluid lineHeight={3} icon={icon} onClick={() => act('setScreen', { setScreen: screen })}>
      {text}
    </Button>
  );
};

const BackButton = () => {
  const { act } = useBackend();
  return (
    <Button icon="arrow-left" onClick={() => act('setScreen', { setScreen: 0 })}>
      Back
    </Button>
  );
};

const MainMenu = () => {
  const { act, data } = useBackend<RequestConsoleData>();
  const { newmessagepriority, announcementConsole, silent } = data;
  let messageInfo;
  if (newmessagepriority === MsgPriority.RQ_HIGHPRIORITY) {
    messageInfo = (
      <Blink>
        <Box color="red" bold mb={1}>
          NEW PRIORITY MESSAGES
        </Box>
      </Blink>
    );
  } else if (newmessagepriority > MsgPriority.RQ_NONEW_MESSAGES) {
    messageInfo = (
      <Box color="red" bold mb={1}>
        There are new messages
      </Box>
    );
  } else {
    messageInfo = (
      <Box color="label" mb={1}>
        There are no new messages
      </Box>
    );
  }
  return (
    <Stack.Item grow textAlign="center">
      <Section
        fill
        scrollable
        title="Main Menu"
        buttons={
          <Button
            width={9}
            selected={!silent}
            icon={silent ? 'volume-mute' : 'volume-up'}
            onClick={() => act('toggleSilent')}
          >
            {silent ? 'Speaker Off' : 'Speaker On'}
          </Button>
        }
      >
        {messageInfo}
        <Box>
          <MainMenuButton
            icon={newmessagepriority > MsgPriority.RQ_NONEW_MESSAGES ? 'envelope-open-text' : 'envelope'}
            screen={6}
            text="View Messages"
          />
        </Box>
        <Box mt={1}>
          <MainMenuButton icon="hand-paper" screen={1} text="Request Assistance" />
          <MainMenuButton icon="box" screen={2} text="Request Supplies" />
          <MainMenuButton icon="clipboard-list" screen={11} text="Request Secondary Goal" />
          <MainMenuButton icon="comment" screen={3} text="Relay Anonymous Information" />
        </Box>
        <Box mt={1}>
          <MainMenuButton icon="tag" screen={9} text="Print Shipping Label" />
          <MainMenuButton icon="clipboard-list" screen={10} text="View Shipping Logs" />
        </Box>
        {!!announcementConsole && (
          <Box mt={1}>
            <MainMenuButton icon="bullhorn" screen={8} text="Send Station-Wide Announcement" />
          </Box>
        )}
      </Section>
    </Stack.Item>
  );
};

const DepartmentList = (props) => {
  const { act, data } = useBackend<RequestConsoleData>();
  const { department, assist_dept, supply_dept, info_dept } = data;

  let list2iterate: string[] = [];
  let sectionTitle;
  switch (props.purpose) {
    case 'ASSISTANCE':
      list2iterate = assist_dept;
      sectionTitle = 'Request assistance from another department';
      break;
    case 'SUPPLIES':
      list2iterate = supply_dept;
      sectionTitle = 'Request supplies from another department';
      break;
    case 'INFO':
      list2iterate = info_dept;
      sectionTitle = 'Relay information to another department';
      break;
  }
  return (
    <Stack.Item grow>
      <Section fill scrollable title={sectionTitle} buttons={<BackButton />}>
        <LabeledList>
          {list2iterate
            .filter((d) => d !== department)
            .map((d) => (
              <LabeledList.Item key={d} label={d} textAlign="right" className="candystripe">
                <Button
                  icon="envelope"
                  onClick={() => act('writeInput', { write: d, priority: MsgPriority.RQ_NORMALPRIORITY })}
                >
                  Message
                </Button>
                <Button
                  icon="exclamation-circle"
                  onClick={() => act('writeInput', { write: d, priority: MsgPriority.RQ_HIGHPRIORITY })}
                >
                  High Priority
                </Button>
              </LabeledList.Item>
            ))}
        </LabeledList>
      </Section>
    </Stack.Item>
  );
};

const MessageResponse = (props) => {
  const { type } = props;
  let sectionTitle;
  switch (type) {
    case 'SUCCESS':
      sectionTitle = 'Message sent successfully';
      break;
    case 'FAIL':
      sectionTitle = 'Unable to contact messaging server';
      break;
  }

  return <Section fill title={sectionTitle} buttons={<BackButton />} />;
};

const MessageLog = (props: { type: string }) => {
  const { act, data } = useBackend<RequestConsoleData>();
  const { message_log, shipping_log } = data;

  let list2iterate: string[][] = [];
  let sectionTitle;
  switch (props.type) {
    case 'MESSAGES':
      list2iterate = message_log;
      sectionTitle = 'Message Log';
      break;
    case 'SHIPPING':
      list2iterate = shipping_log;
      sectionTitle = 'Shipping label print log';
      break;
  }
  list2iterate.reverse();

  return (
    <Stack.Item grow textAlign="center">
      <Section fill scrollable title={sectionTitle} buttons={<BackButton />}>
        {list2iterate.map((m, i) => (
          <Box key={i} textAlign="left">
            {m.map((msg, key) => {
              return <div key={key}>{msg}</div>;
            })}
            <hr />
          </Box>
        ))}
      </Section>
    </Stack.Item>
  );
};

const MessageAuth = () => {
  const { act, data } = useBackend<RequestConsoleData>();
  const { recipient, message, msgVerified, msgStamped } = data;

  return (
    <>
      <Stack.Item grow textAlign="center">
        <Section fill scrollable title="Message Authentication" buttons={<BackButton />}>
          <LabeledList>
            <LabeledList.Item label="Recipient">{recipient}</LabeledList.Item>
            <LabeledList.Item label="Message">{message}</LabeledList.Item>
            <LabeledList.Item label="Validated by" color="green">
              {msgVerified}
            </LabeledList.Item>
            <LabeledList.Item label="Stamped by" color="blue">
              {msgStamped}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section>
          <Button fluid textAlign="center" icon="envelope" onClick={() => act('department', { department: recipient })}>
            Send Message
          </Button>
        </Section>
      </Stack.Item>
    </>
  );
};

const StationAnnouncement = () => {
  const { act, data } = useBackend<RequestConsoleData>();
  const { message, announceAuth } = data;

  return (
    <>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title="Station-Wide Announcement"
          buttons={
            <>
              <BackButton />
              <Button icon="edit" onClick={() => act('writeAnnouncement')}>
                Edit Message
              </Button>
            </>
          }
        >
          {message}
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section>
          {announceAuth ? (
            <Box textAlign="center" color="green">
              ID verified. Authentication accepted.
            </Box>
          ) : (
            <Box textAlign="center" color="label">
              Swipe your ID card to authenticate yourself
            </Box>
          )}
          <Button
            fluid
            mt={2}
            textAlign="center"
            icon="bullhorn"
            disabled={!(announceAuth && message)}
            onClick={() => act('sendAnnouncement')}
          >
            Send Announcement
          </Button>
        </Section>
      </Stack.Item>
    </>
  );
};

const PrintShippingLabel = () => {
  const { act, data } = useBackend<RequestConsoleData>();
  const { shipDest, msgVerified, ship_dept } = data;

  return (
    <>
      <Stack.Item textAlign="center">
        <Section title="Print Shipping Label" buttons={<BackButton />}>
          <LabeledList>
            <LabeledList.Item label="Destination">{shipDest}</LabeledList.Item>
            <LabeledList.Item label="Validated by">{msgVerified}</LabeledList.Item>
          </LabeledList>
          <Button
            fluid
            mt={1}
            textAlign="center"
            icon="print"
            disabled={!(shipDest && msgVerified)}
            onClick={() => act('printLabel')}
          >
            Print Label
          </Button>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title="Destinations">
          <LabeledList>
            {ship_dept.map((d) => (
              <LabeledList.Item label={d} key={d} textAlign="right" className="candystripe">
                <Button selected={shipDest === d} onClick={() => act('shipSelect', { shipSelect: d })}>
                  {shipDest === d ? 'Selected' : 'Select'}
                </Button>
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Stack.Item>
    </>
  );
};

const SecondaryGoal = () => {
  const { act, data } = useBackend<RequestConsoleData>();
  const { secondaryGoalAuth, secondaryGoalEnabled } = data;

  return (
    <>
      <Stack.Item grow>
        <Section fill scrollable title="Request Secondary Goal" buttons={<BackButton />} />
      </Stack.Item>
      <Stack.Item>
        <Section>
          {secondaryGoalEnabled ? (
            secondaryGoalAuth ? (
              <Box textAlign="center" color="green">
                ID verified. Authentication accepted.
              </Box>
            ) : (
              <Box textAlign="center" color="label">
                Swipe your ID card to authenticate yourself
              </Box>
            )
          ) : (
            <Box textAlign="center" color="label">
              Complete your current goal first!
            </Box>
          )}
          <Button
            fluid
            mt={2}
            textAlign="center"
            icon="clipboard-list"
            disabled={!(secondaryGoalAuth && secondaryGoalEnabled)}
            onClick={() => act('requestSecondaryGoal')}
          >
            Request Secondary Goal
          </Button>
        </Section>
      </Stack.Item>
    </>
  );
};
