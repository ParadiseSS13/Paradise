import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, LabeledList, Box, Section } from '../components';
import { Window } from '../layouts';

export const CommunicationsComputer = (props, context) => {
  const { act, data } = useBackend(context);

  let authReadable;
  let authSpecial = false;
  if (!data.authenticated) {
    authReadable = "Not Logged In";
  } else if (data.authenticated === 1) {
    authReadable = "Command";
  } else if (data.authenticated === 2) {
    authReadable = "Captain";
  } else if (data.authenticated === 3) {
    authReadable = "CentComm Secure Connection";
    authSpecial = true;
  } else {
    authReadable = "ERROR: Report This Bug!";
  }
  let reportText = "View (" + data.messages.length + ")";
  let authBlock = (
    <Fragment>
      <Section title="Authentication">
        <LabeledList>
          {authSpecial && (
            <LabeledList.Item label="Access">
              {authReadable}
            </LabeledList.Item>
          ) || (
            <LabeledList.Item label="Actions">
              <Button
                icon={data.authenticated ? 'sign-out-alt' : 'id-card'}
                selected={data.authenticated}
                disabled={data.noauthbutton}
                content={data.authenticated
                  ? "Log Out (" + authReadable + ")"
                  : 'Log In'}
                onClick={() => act("auth")} />
            </LabeledList.Item>
          )}
        </LabeledList>
      </Section>
      {!!data.esc_section && (
        <Section title="Escape Shuttle">
          <LabeledList>
            {!!data.esc_status && (
              <LabeledList.Item label="Status">
                {data.esc_status}
              </LabeledList.Item>
            )}
            {!!data.esc_callable && (
              <LabeledList.Item label="Options">
                <Button
                  icon="rocket"
                  content="Call Shuttle"
                  disabled={!data.authhead}
                  onClick={() => act('callshuttle')} />
              </LabeledList.Item>
            )}
            {!!data.esc_recallable && (
              <LabeledList.Item label="Options">
                <Button
                  icon="times"
                  content="Recall Shuttle"
                  disabled={!data.authhead || data.is_ai}
                  onClick={() => act('cancelshuttle')} />
              </LabeledList.Item>
            )}
            {!!data.lastCallLoc && (
              <LabeledList.Item label="Last Call/Recall From">
                {data.lastCallLoc}
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      )}
    </Fragment>
  );
  let announceText = "Make Priority Announcement";
  if (data.msg_cooldown > 0) {
    announceText += " (" + data.msg_cooldown + "s)";
  }
  let ccMessageText = data.emagged ? "Message [UNKNOWN]" : "Message CentComm";
  let nukeRequestText = "Request Authentication Codes";
  if (data.cc_cooldown > 0) {
    ccMessageText += " (" + data.cc_cooldown + "s)";
    nukeRequestText += " (" + data.cc_cooldown + "s)";
  }
  let alertLevelText = data.str_security_level;
  let alertLevelButtons = data.levels.map(slevel => {
    return (
      <Button
        key={slevel.name}
        icon={slevel.icon}
        content={slevel.name}
        disabled={!data.authcapt
          || slevel.id === data.security_level}
        onClick={() => act('newalertlevel', { level: slevel.id })} />
    );
  });
  let presetButtons = data.stat_display["presets"].map(pb => {
    return (
      <Button
        key={pb.name}
        content={pb.label}
        selected={pb.name === data.stat_display.type}
        disabled={!data.authhead}
        onClick={() => act('setstat', { statdisp: pb.name })} />
    );
  });
  let iconButtons = data.stat_display["alerts"].map(ib => {
    return (
      <Button
        key={ib.alert}
        content={ib.label}
        selected={ib.alert === data.stat_display.icon}
        disabled={!data.authhead}
        onClick={() => act('setstat',
          { statdisp: "alert", alert: ib.alert })} />
    );
  });
  let messageView;
  if (data.current_message_title) {
    messageView = (
      <Section title={data.current_message_title} buttons={
        <Button
          icon="times"
          content="Return To Message List"
          disabled={!data.authhead}
          onClick={() => act('messagelist')} />
      }>
        <Box>
          {data.current_message}
        </Box>
      </Section>
    );
  } else {
    let messageRows = data.messages.map(m => {
      return (
        <LabeledList.Item key={m.id} label={m.title}>
          <Button
            icon="eye"
            content="View"
            disabled={!data.authhead
              || data.current_message_title === m.title}
            onClick={() => act('messagelist', { msgid: m.id })} />
          <Button
            icon="times"
            content="Delete"
            disabled={!data.authhead}
            onClick={() => act('delmessage', { msgid: m.id })} />
        </LabeledList.Item>
      );
    });
    messageView = (
      <Section title="Messages Received" buttons={
        <Button
          icon="arrow-circle-left"
          content="Back To Main Menu"
          onClick={() => act('main')} />
      }>
        <LabeledList>
          {messageRows}
        </LabeledList>
      </Section>
    );
  }
  switch (data.menu_state) {
    // 1 = main screen
    case 1:
      return (
        <Window resizable>
          <Window.Content scrollable>
            {authBlock}
            <Section title="Priority Actions">
              <LabeledList>
                <LabeledList.Item label="Current Alert"
                  color={data.security_level_color}>
                  {alertLevelText}
                </LabeledList.Item>
                <LabeledList.Item label="Change Alert">
                  {alertLevelButtons}
                </LabeledList.Item>
                <LabeledList.Item label="Announcement">
                  <Button
                    icon="bullhorn"
                    content={announceText}
                    disabled={!data.authcapt || data.msg_cooldown > 0}
                    onClick={() => act('announce')} />
                </LabeledList.Item>
                {!!data.emagged && (
                  <LabeledList.Item label="Transmit">
                    <Button
                      icon="broadcast-tower"
                      color="red"
                      content={ccMessageText}
                      disabled={!data.authcapt || data.cc_cooldown > 0}
                      onClick={() => act('MessageSyndicate')} />
                    <Button
                      icon="sync-alt"
                      content="Reset Relays"
                      disabled={!data.authcapt}
                      onClick={() => act('RestoreBackup')} />
                  </LabeledList.Item>
                ) || (
                  <LabeledList.Item label="Transmit">
                    <Button
                      icon="broadcast-tower"
                      content={ccMessageText}
                      disabled={!data.authcapt || data.cc_cooldown > 0}
                      onClick={() => act('MessageCentcomm')} />
                  </LabeledList.Item>
                )}
                <LabeledList.Item label="Nuclear Device">
                  <Button
                    icon="bomb"
                    content={nukeRequestText}
                    disabled={!data.authcapt || data.cc_cooldown > 0}
                    onClick={() => act('nukerequest')} />
                </LabeledList.Item>
              </LabeledList>
            </Section>
            <Section title="Command Staff Actions">
              <LabeledList>
                <LabeledList.Item label="Displays">
                  <Button
                    icon="tv"
                    content="Change Status Displays"
                    disabled={!data.authhead}
                    onClick={() => act('status')} />
                </LabeledList.Item>
                <LabeledList.Item label="Incoming Messages">
                  <Button
                    icon="folder-open"
                    content={reportText}
                    disabled={!data.authhead}
                    onClick={() => act('messagelist')} />
                </LabeledList.Item>
                <LabeledList.Item label="Misc">
                  <Button
                    icon="sync-alt"
                    content="Restart Nano-Mob Hunter GO! Server"
                    disabled={!data.authhead}
                    onClick={() => act('RestartNanoMob')} />
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Window.Content>
        </Window>
      );

    // 2 = status screen
    case 2:

      return (
        <Window>
          <Window.Content>
            {authBlock}
            <Section title="Modify Status Screens" buttons={
              <Button
                icon="arrow-circle-left"
                content="Back To Main Menu"
                onClick={() => act('main')} />
            }>
              <LabeledList>
                <LabeledList.Item label="Presets">
                  {presetButtons}
                </LabeledList.Item>
                <LabeledList.Item label="Alerts">
                  {iconButtons}
                </LabeledList.Item>
                <LabeledList.Item label="Message Line 1">
                  <Button
                    icon="pencil-alt"
                    content={data.stat_display.line_1}
                    disabled={!data.authhead}
                    onClick={() => act('setmsg1')} />
                </LabeledList.Item>
                <LabeledList.Item label="Message Line 2">
                  <Button
                    icon="pencil-alt"
                    content={data.stat_display.line_2}
                    disabled={!data.authhead}
                    onClick={() => act('setmsg2')} />
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Window.Content>
        </Window>
      );


    // 3 = messages screen
    case 3:
      return (
        <Window>
          <Window.Content>
            {authBlock}
            {messageView}
          </Window.Content>
        </Window>
      );

    default:
      return (
        <Window>
          <Window.Content>
            {authBlock}
            ERRROR. Unknown menu_state: {data.menu_state}
            Please report this to NT Technical Support.
          </Window.Content>
        </Window>
      );

  }

};
