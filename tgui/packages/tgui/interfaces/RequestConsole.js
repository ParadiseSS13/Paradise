import { useBackend } from '../backend';
import { Button, LabeledList, Box, Section, Stack, Blink } from '../components';
import { Window } from '../layouts';

const RQ_NONEW_MESSAGES = 0;
const RQ_LOWPRIORITY = 1;
const RQ_NORMALPRIORITY = 2;
const RQ_HIGHPRIORITY = 3;

export const RequestConsole = (props, context) => {
  const { act, data } = useBackend(context);
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
    <Window width={450} height={announcementConsole ? 425 : 385}>
      <Window.Content scrollable>
        <Stack fill vertical>
          {pickPage(screen)}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MainMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const { newmessagepriority, announcementConsole, silent } = data;
  let messageInfo;
  if (newmessagepriority >= RQ_NONEW_MESSAGES) {
    messageInfo = (
      <Box color="red" bold mb={1}>
        There are new messages
      </Box>
    );
  } else if (newmessagepriority === RQ_HIGHPRIORITY) {
    messageInfo = (
      <Blink>
        <Box color="red" bold mb={1}>
          NEW PRIORITY MESSAGES
        </Box>
      </Blink>
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
            content={silent ? 'Speaker Off' : 'Speaker On'}
            selected={!silent}
            icon={silent ? 'volume-mute' : 'volume-up'}
            onClick={() => act('toggleSilent')}
          />
        }
      >
        {messageInfo}
        <Stack.Item>
          <Button
            fluid
            lineHeight={3}
            color="translucent"
            content="View Messages"
            icon={newmessagepriority > RQ_NONEW_MESSAGES ? 'envelope-open-text' : 'envelope'}
            onClick={() => act('setScreen', { setScreen: 6 })}
          />
        </Stack.Item>
        <Stack.Item mt={1}>
          <Button
            fluid
            lineHeight={3}
            color="translucent"
            content="Request Assistance"
            icon="hand-paper"
            onClick={() => act('setScreen', { setScreen: 1 })}
          />
          <Stack.Item>
            <Button
              fluid
              lineHeight={3}
              color="translucent"
              content="Request Supplies"
              icon="box"
              onClick={() => act('setScreen', { setScreen: 2 })}
            />
            <Button
              fluid
              lineHeight={3}
              color="translucent"
              content="Request Secondary Goal"
              icon="clipboard-list"
              onClick={() => act('setScreen', { setScreen: 11 })}
            />
            <Button
              fluid
              lineHeight={3}
              color="translucent"
              content="Relay Anonymous Information"
              icon="comment"
              onClick={() => act('setScreen', { setScreen: 3 })}
            />
          </Stack.Item>
        </Stack.Item>
        <Stack.Item mt={1}>
          <Stack.Item>
            <Button
              fluid
              lineHeight={3}
              color="translucent"
              content="Print Shipping Label"
              icon="tag"
              onClick={() => act('setScreen', { setScreen: 9 })}
            />
            <Button
              fluid
              lineHeight={3}
              color="translucent"
              content="View Shipping Logs"
              icon="clipboard-list"
              onClick={() => act('setScreen', { setScreen: 10 })}
            />
          </Stack.Item>
        </Stack.Item>
        {!!announcementConsole && (
          <Stack.Item mt={1}>
            <Button
              fluid
              lineHeight={3}
              color="translucent"
              content="Send Station-Wide Announcement"
              icon="bullhorn"
              onClick={() => act('setScreen', { setScreen: 8 })}
            />
          </Stack.Item>
        )}
      </Section>
    </Stack.Item>
  );
};

const DepartmentList = (props, context) => {
  const { act, data } = useBackend(context);
  const { department } = data;

  let list2iterate = [];
  let sectionTitle;
  switch (props.purpose) {
    case 'ASSISTANCE':
      list2iterate = data.assist_dept;
      sectionTitle = 'Request assistance from another department';
      break;
    case 'SUPPLIES':
      list2iterate = data.supply_dept;
      sectionTitle = 'Request supplies from another department';
      break;
    case 'INFO':
      list2iterate = data.info_dept;
      sectionTitle = 'Relay information to another department';
      break;
  }
  return (
    <Stack.Item grow>
      <Section
        fill
        scrollable
        title={sectionTitle}
        buttons={<Button content="Back" icon="arrow-left" onClick={() => act('setScreen', { setScreen: 0 })} />}
      >
        <LabeledList>
          {list2iterate
            .filter((d) => d !== department)
            .map((d) => (
              <LabeledList.Item key={d} label={d} textAlign="right" className="candystripe">
                <Button
                  content="Message"
                  icon="envelope"
                  onClick={() => act('writeInput', { write: d, priority: RQ_NORMALPRIORITY })}
                />
                <Button
                  content="High Priority"
                  icon="exclamation-circle"
                  onClick={() => act('writeInput', { write: d, priority: RQ_HIGHPRIORITY })}
                />
              </LabeledList.Item>
            ))}
        </LabeledList>
      </Section>
    </Stack.Item>
  );
};

const MessageResponse = (props, context) => {
  const { act, data } = useBackend(context);

  let sectionTitle;
  switch (props.type) {
    case 'SUCCESS':
      sectionTitle = 'Message sent successfully';
      break;
    case 'FAIL':
      sectionTitle = 'Unable to contact messaging server';
      break;
  }

  return (
    <Section
      fill
      title={sectionTitle}
      buttons={<Button content="Back" icon="arrow-left" onClick={() => act('setScreen', { setScreen: 0 })} />}
    />
  );
};

const MessageLog = (props, context) => {
  const { act, data } = useBackend(context);

  let list2iterate;
  let sectionTitle;
  switch (props.type) {
    case 'MESSAGES':
      list2iterate = data.message_log;
      sectionTitle = 'Message Log';
      break;
    case 'SHIPPING':
      list2iterate = data.shipping_log;
      sectionTitle = 'Shipping label print log';
      break;
  }
  list2iterate.reverse();

  return (
    <Stack.Item grow textAlign="center">
      <Section
        fill
        scrollable
        title={sectionTitle}
        buttons={<Button content="Back" icon="arrow-left" onClick={() => act('setScreen', { setScreen: 0 })} />}
      >
        {list2iterate.map((m) => (
          <Box key={m} textAlign="left">
            {m.map((i, key) => {
              return <div key={key}>{i}</div>;
            })}
            <hr />
          </Box>
        ))}
      </Section>
    </Stack.Item>
  );
};

const MessageAuth = (props, context) => {
  const { act, data } = useBackend(context);
  const { recipient, message, msgVerified, msgStamped } = data;

  return (
    <>
      <Stack.Item grow textAlign="center">
        <Section
          fill
          scrollable
          title="Message Authentication"
          buttons={<Button content="Back" icon="arrow-left" onClick={() => act('setScreen', { setScreen: 0 })} />}
        >
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
          <Button
            fluid
            textAlign="center"
            content="Send Message"
            icon="envelope"
            onClick={() => act('department', { department: recipient })}
          />
        </Section>
      </Stack.Item>
    </>
  );
};

const StationAnnouncement = (props, context) => {
  const { act, data } = useBackend(context);
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
              <Button content="Back" icon="arrow-left" onClick={() => act('setScreen', { setScreen: 0 })} />
              <Button content="Edit Message" icon="edit" onClick={() => act('writeAnnouncement')} />
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
            content="Send Announcement"
            icon="bullhorn"
            disabled={!(announceAuth && message)}
            onClick={() => act('sendAnnouncement')}
          />
        </Section>
      </Stack.Item>
    </>
  );
};

const PrintShippingLabel = (props, context) => {
  const { act, data } = useBackend(context);
  const { shipDest, msgVerified, ship_dept } = data;

  return (
    <>
      <Stack.Item textAlign="center">
        <Section
          title="Print Shipping Label"
          buttons={<Button content="Back" icon="arrow-left" onClick={() => act('setScreen', { setScreen: 0 })} />}
        >
          <LabeledList>
            <LabeledList.Item label="Destination">{shipDest}</LabeledList.Item>
            <LabeledList.Item label="Validated by">{msgVerified}</LabeledList.Item>
          </LabeledList>
          <Button
            fluid
            mt={1}
            textAlign="center"
            content="Print Label"
            icon="print"
            disabled={!(shipDest && msgVerified)}
            onClick={() => act('printLabel')}
          />
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title="Destinations">
          <LabeledList>
            {ship_dept.map((d) => (
              <LabeledList.Item label={d} key={d} textAlign="right" className="candystripe">
                <Button
                  content={shipDest === d ? 'Selected' : 'Select'}
                  selected={shipDest === d}
                  onClick={() => act('shipSelect', { shipSelect: d })}
                />
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Stack.Item>
    </>
  );
};

const SecondaryGoal = (props, context) => {
  const { act, data } = useBackend(context);
  const { secondaryGoalAuth, secondaryGoalEnabled } = data;

  return (
    <>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title="Request Secondary Goal"
          buttons={<Button content="Back" icon="arrow-left" onClick={() => act('setScreen', { setScreen: 0 })} />}
        />
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
            content="Request Secondary Goal"
            icon="clipboard-list"
            disabled={!(secondaryGoalAuth && secondaryGoalEnabled)}
            onClick={() => act('requestSecondaryGoal')}
          />
        </Section>
      </Stack.Item>
    </>
  );
};
