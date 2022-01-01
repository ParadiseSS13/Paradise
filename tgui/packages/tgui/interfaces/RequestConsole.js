import { useBackend } from "../backend";
import { Button, LabeledList, Box, Section } from "../components";
import { Window } from "../layouts";

export const RequestConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    screen,
  } = data;

  const pickPage = index => {
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
      default:
        return "WE SHOULDN'T BE HERE!";
    }
  };

  return (
    <Window>
      <Window.Content scrollable>
        {pickPage(screen)}
      </Window.Content>
    </Window>
  );
};

const MainMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    newmessagepriority,
    announcementConsole,
    silent,
  } = data;
  let messageInfo;
  if (newmessagepriority === 1) {
    messageInfo = (
      <Box color="red">
        There are new messages
      </Box>
    );
  } else if (newmessagepriority === 2) {
    messageInfo = (
      <Box color="red" bold>
        NEW PRIORITY MESSAGES
      </Box>
    );
  }
  return (
    <Section title="Main Menu">
      {messageInfo}
      <Box mt={2}>
        <Button
          content="View Messages"
          icon={newmessagepriority > 0 ? "envelope-open-text" : "envelope"}
          onClick={
            () => act('setScreen', { setScreen: 6 })
          } />
      </Box>
      <Box mt={2}>
        <Box>
          <Button
            content="Request Assistance"
            icon="hand-paper"
            onClick={
              () => act('setScreen', { setScreen: 1 })
            } />
        </Box>
        <Box>
          <Button
            content="Request Supplies"
            icon="box"
            onClick={
              () => act('setScreen', { setScreen: 2 })
            } />
        </Box>
        <Box>
          <Button
            content="Relay Anonymous Information"
            icon="comment"
            onClick={
              () => act('setScreen', { setScreen: 3 })
            } />
        </Box>
      </Box>
      <Box mt={2}>
        <Box>
          <Button
            content="Print Shipping Label"
            icon="tag"
            onClick={
              () => act('setScreen', { setScreen: 9 })
            } />
        </Box>
        <Box>
          <Button
            content="View Shipping Logs"
            icon="clipboard-list"
            onClick={
              () => act('setScreen', { setScreen: 10 })
            } />
        </Box>
      </Box>
      {!!announcementConsole && (
        <Box mt={2}>
          <Button
            content="Send Station-Wide Announcement"
            icon="bullhorn"
            onClick={
              () => act('setScreen', { setScreen: 8 })
            } />
        </Box>
      )}
      <Box mt={2}>
        <Button
          content={silent ? "Speaker Off" : "Speaker On"}
          selected={!silent}
          icon={silent ? "volume-mute" : "volume-up"}
          onClick={
            () => act('toggleSilent')
          } />
      </Box>
    </Section>
  );
};

const DepartmentList = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    department,
  } = data;

  let list2iterate;
  let sectionTitle;
  switch (props.purpose) {
    case "ASSISTANCE":
      list2iterate = data.assist_dept;
      sectionTitle = "Request assistance from another department";
      break;
    case "SUPPLIES":
      list2iterate = data.supply_dept;
      sectionTitle = "Request supplies from another department";
      break;
    case "INFO":
      list2iterate = data.info_dept;
      sectionTitle = "Relay information to another department";
      break;
  }
  return (
    <Section title={sectionTitle} buttons={
      <Button
        content="Back"
        icon="arrow-left"
        onClick={
          () => act('setScreen', { setScreen: 0 })
        } />
    }>
      <LabeledList>
        {list2iterate.filter(d => (d !== department)).map(d => (
          <LabeledList.Item key={d} label={d}>
            <Button
              content="Message"
              icon="envelope"
              onClick={
                () => act('writeInput', { write: d, priority: 1 })
              } />
            <Button
              content="High Priority"
              icon="exclamation-circle"
              onClick={
                () => act('writeInput', { write: d, priority: 2 })
              } />
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
};

const MessageResponse = (props, context) => {
  const { act, data } = useBackend(context);

  let sectionTitle;
  switch (props.type) {
    case "SUCCESS":
      sectionTitle = "Message sent successfully";
      break;
    case "FAIL":
      sectionTitle = "Request supplies from another department";
      break;
  }

  return (
    <Section title={sectionTitle} buttons={
      <Button
        content="Back"
        icon="arrow-left"
        onClick={
          () => act('setScreen', { setScreen: 0 })
        } />
    } />
  );
};

const MessageLog = (props, context) => {
  const { act, data } = useBackend(context);

  let list2iterate;
  let sectionTitle;
  switch (props.type) {
    case "MESSAGES":
      list2iterate = data.message_log;
      sectionTitle = "Message Log";
      break;
    case "SHIPPING":
      list2iterate = data.shipping_log;
      sectionTitle = "Shipping label print log";
      break;
  }

  return (
    <Section title={sectionTitle} buttons={
      <Button
        content="Back"
        icon="arrow-left"
        onClick={
          () => act('setScreen', { setScreen: 0 })
        } />
    } >
      {list2iterate.map(m => (
        <Box className="RequestConsole__message" key={m}>
          {m}
        </Box>
      ))}
    </Section>
  );
};

const MessageAuth = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    recipient,
    message,
    msgVerified,
    msgStamped,
  } = data;

  return (
    <Section title="Message Authentication" buttons={
      <Button
        content="Back"
        icon="arrow-left"
        onClick={
          () => act('setScreen', { setScreen: 0 })
        } />
    } >
      <LabeledList>
        <LabeledList.Item label="Recipient">
          {recipient}
        </LabeledList.Item>
        <LabeledList.Item label="Message">
          {message}
        </LabeledList.Item>
        <LabeledList.Item label="Validated by" color="green">
          {msgVerified}
        </LabeledList.Item>
        <LabeledList.Item label="Stamped by" color="blue">
          {msgStamped}
        </LabeledList.Item>
      </LabeledList>
      <Button
        fluid
        mt={1}
        textAlign="center"
        content="Send Message"
        icon="envelope"
        onClick={
          () => act('department', { department: recipient })
        } />
    </Section>
  );
};

const StationAnnouncement = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    message,
    announceAuth,
  } = data;

  return (
    <Section title="Station-Wide Announcement" buttons={
      <Button
        content="Back"
        icon="arrow-left"
        onClick={
          () => act('setScreen', { setScreen: 0 })
        } />
    } >
      <Button
        content={message ? message : "Edit Message"}
        icon="edit"
        onClick={
          () => act('writeAnnouncement')
        } />
      {announceAuth ? (
        <Box mt={1} color="green">
          ID verified. Authentication accepted.
        </Box>
      ) : (
        <Box mt={1}>
          Swipe your ID card to authenticate yourself.
        </Box>
      )}
      <Button
        fluid
        mt={1}
        textAlign="center"
        content="Send Announcement"
        icon="bullhorn"
        disabled={!(announceAuth && message)}
        onClick={
          () => act('sendAnnouncement')
        } />
    </Section>
  );
};

const PrintShippingLabel = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    shipDest,
    msgVerified,
    ship_dept,
  } = data;

  return (
    <Section title="Print Shipping Label" buttons={
      <Button
        content="Back"
        icon="arrow-left"
        onClick={
          () => act('setScreen', { setScreen: 0 })
        } />
    } >
      <LabeledList>
        <LabeledList.Item label="Destination">
          {shipDest}
        </LabeledList.Item>
        <LabeledList.Item label="Validated by">
          {msgVerified}
        </LabeledList.Item>
      </LabeledList>
      <Button
        fluid
        mt={1}
        textAlign="center"
        content="Print Label"
        icon="print"
        disabled={!(shipDest && msgVerified)}
        onClick={
          () => act('printLabel')
        } />
      <Section title="Destinations" mt={1}>
        <LabeledList>
          {ship_dept.map(d => (
            <LabeledList.Item label={d} key={d}>
              <Button
                content={shipDest === d ? "Selected" : "Select"}
                selected={shipDest === d}
                onClick={
                  () => act('shipSelect', { shipSelect: d })
                } />
            </LabeledList.Item>
          ))}
        </LabeledList>
      </Section>
    </Section>
  );
};
