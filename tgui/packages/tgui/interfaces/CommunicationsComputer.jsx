import { useState } from 'react';
import { Box, Button, Collapsible, Dropdown, Input, LabeledList, Section, Stack, TextArea } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const PickWindow = (index) => {
  switch (index) {
    case 1:
      return <MainPage />;
    case 2:
      return <StatusScreens />;
    case 3:
      return (
        <Stack.Item grow>
          <Section fill>
            <MessageView />
          </Section>
        </Stack.Item>
      );
    case 4:
      return <AdminAnnouncePage />;
    default:
      return 'ERROR. Unknown menu_state. Please contact NT Technical Support.';
  }
};

export const CommunicationsComputer = (props) => {
  const { act, data } = useBackend();
  const { menu_state } = data;

  return (
    <Window width={500} height={600}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <AuthBlock />
          {PickWindow(menu_state)}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const AuthBlock = (props) => {
  const { act, data } = useBackend();

  const {
    authenticated,
    noauthbutton,
    esc_section,
    esc_callable,
    esc_recallable,
    esc_status,
    authhead,
    is_ai,
    lastCallLoc,
  } = data;

  let hideLogButton = false;
  let authReadable;
  if (!authenticated) {
    authReadable = 'Not Logged In';
  } else if (authenticated === 1) {
    authReadable = 'Command';
  } else if (authenticated === 2) {
    authReadable = 'Captain';
  } else if (authenticated === 3) {
    authReadable = 'CentComm Officer';
  } else if (authenticated === 4) {
    authReadable = 'CentComm Secure Connection';
    hideLogButton = true;
  } else {
    authReadable = 'ERROR: Report This Bug!';
  }

  return (
    <>
      <Stack.Item>
        <Section title="Authentication">
          <LabeledList>
            {(hideLogButton && <LabeledList.Item label="Access">{authReadable}</LabeledList.Item>) || (
              <LabeledList.Item label="Actions">
                <Button
                  icon={authenticated ? 'sign-out-alt' : 'id-card'}
                  selected={authenticated}
                  disabled={noauthbutton}
                  content={authenticated ? 'Log Out (' + authReadable + ')' : 'Log In'}
                  onClick={() => act('auth')}
                />
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item>
        {!!esc_section && (
          <Section fill title="Escape Shuttle">
            <LabeledList>
              {!!esc_status && <LabeledList.Item label="Status">{esc_status}</LabeledList.Item>}
              {!!esc_callable && (
                <LabeledList.Item label="Options">
                  <Button
                    icon="rocket"
                    content="Call Shuttle"
                    disabled={!authhead}
                    onClick={() => act('callshuttle')}
                  />
                </LabeledList.Item>
              )}
              {!!esc_recallable && (
                <LabeledList.Item label="Options">
                  <Button
                    icon="times"
                    content="Recall Shuttle"
                    disabled={!authhead || is_ai}
                    onClick={() => act('cancelshuttle')}
                  />
                </LabeledList.Item>
              )}
              {!!lastCallLoc && <LabeledList.Item label="Last Call/Recall From">{lastCallLoc}</LabeledList.Item>}
            </LabeledList>
          </Section>
        )}
      </Stack.Item>
    </>
  );
};

const MainPage = (props) => {
  const { act, data } = useBackend();

  const { is_admin } = data;

  if (is_admin) {
    return <AdminPage />;
  }
  return <PlayerPage />;
};

const AdminPage = (props) => {
  const { act, data } = useBackend();
  const { is_admin, gamma_armory_location, admin_levels, authenticated, ert_allowed } = data;

  return (
    <Stack.Item>
      <Section title="CentComm Actions">
        <LabeledList>
          <LabeledList.Item label="Change Alert">
            <MappedAlertLevelButtons levels={admin_levels} required_access={is_admin} use_confirm={1} />
          </LabeledList.Item>
          <LabeledList.Item label="Announcement">
            <Button
              icon="bullhorn"
              content="Make Central Announcement"
              disabled={!is_admin}
              onClick={() => act('send_to_cc_announcement_page')}
            />
            {authenticated === 4 && (
              <Button
                icon="plus"
                content="Make Other Announcement"
                disabled={!is_admin}
                onClick={() => act('make_other_announcement')}
              />
            )}
          </LabeledList.Item>
          <LabeledList.Item label="Response Team">
            <Button icon="ambulance" content="Dispatch ERT" disabled={!is_admin} onClick={() => act('dispatch_ert')} />
            <Button.Checkbox
              checked={ert_allowed}
              content={ert_allowed ? 'ERT calling enabled' : 'ERT calling disabled'}
              tooltip={ert_allowed ? 'Command can request an ERT' : 'ERTs cannot be requested'}
              disabled={!is_admin}
              onClick={() => act('toggle_ert_allowed')}
              selected={null}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Nuclear Device">
            <Button.Confirm
              icon="bomb"
              content="Get Authentication Codes"
              disabled={!is_admin}
              onClick={() => act('send_nuke_codes')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Gamma Armory">
            <Button.Confirm
              icon="biohazard"
              content={gamma_armory_location ? 'Send Gamma Armory' : 'Recall Gamma Armory'}
              disabled={!is_admin}
              onClick={() => act('move_gamma_armory')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Other">
            <Button icon="coins" content="View Economy" disabled={!is_admin} onClick={() => act('view_econ')} />
            <Button icon="fax" content="Fax Manager" disabled={!is_admin} onClick={() => act('view_fax')} />
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Collapsible title="View Command accessible controls">
        <PlayerPage />
      </Collapsible>
    </Stack.Item>
  );
};

const PlayerPage = (props) => {
  const { act, data } = useBackend();

  const {
    msg_cooldown,
    emagged,
    cc_cooldown,
    security_level_color,
    str_security_level,
    levels,
    authcapt,
    authhead,
    messages,
  } = data;

  let announceText = 'Make Priority Announcement';
  if (msg_cooldown > 0) {
    announceText += ' (' + msg_cooldown + 's)';
  }

  let ccMessageText = emagged ? 'Message [UNKNOWN]' : 'Message CentComm';
  let nukeRequestText = 'Request Authentication Codes';
  if (cc_cooldown > 0) {
    ccMessageText += ' (' + cc_cooldown + 's)';
    nukeRequestText += ' (' + cc_cooldown + 's)';
  }

  return (
    <>
      <Stack.Item grow>
        <Section fill title="Captain-Only Actions">
          <LabeledList>
            <LabeledList.Item label="Current Alert" color={security_level_color}>
              {str_security_level}
            </LabeledList.Item>
            <LabeledList.Item label="Change Alert">
              <MappedAlertLevelButtons levels={levels} required_access={authcapt} />
            </LabeledList.Item>
            <LabeledList.Item label="Announcement">
              <Button
                icon="bullhorn"
                content={announceText}
                disabled={!authcapt || msg_cooldown > 0}
                onClick={() => act('announce')}
              />
            </LabeledList.Item>
            {(!!emagged && (
              <LabeledList.Item label="Transmit">
                <Button
                  icon="broadcast-tower"
                  color="red"
                  content={ccMessageText}
                  disabled={!authcapt || cc_cooldown > 0}
                  onClick={() => act('MessageSyndicate')}
                />
                <Button
                  icon="sync-alt"
                  content="Reset Relays"
                  disabled={!authcapt}
                  onClick={() => act('RestoreBackup')}
                />
              </LabeledList.Item>
            )) || (
              <LabeledList.Item label="Transmit">
                <Button
                  icon="broadcast-tower"
                  content={ccMessageText}
                  disabled={!authcapt || cc_cooldown > 0}
                  onClick={() => act('MessageCentcomm')}
                />
              </LabeledList.Item>
            )}
            <LabeledList.Item label="Nuclear Device">
              <Button
                icon="bomb"
                content={nukeRequestText}
                disabled={!authcapt || cc_cooldown > 0}
                onClick={() => act('nukerequest')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section fill title="Command Staff Actions">
          <LabeledList>
            <LabeledList.Item label="Displays">
              <Button icon="tv" content="Change Status Displays" disabled={!authhead} onClick={() => act('status')} />
            </LabeledList.Item>
            <LabeledList.Item label="Incoming Messages">
              <Button
                icon="folder-open"
                content={'View (' + messages.length + ')'}
                disabled={!authhead}
                onClick={() => act('messagelist')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
    </>
  );
};

const StatusScreens = (props) => {
  const { act, data } = useBackend();

  const { stat_display, authhead, current_message_title } = data;

  let presetButtons = stat_display['presets'].map((pb) => {
    return (
      <Button
        key={pb.name}
        content={pb.label}
        selected={pb.name === stat_display.type}
        disabled={!authhead}
        onClick={() => act('setstat', { statdisp: pb.name })}
      />
    );
  });
  let iconButtons = stat_display['alerts'].map((ib) => {
    return (
      <Button
        key={ib.alert}
        content={ib.label}
        selected={ib.alert === stat_display.icon}
        disabled={!authhead}
        onClick={() => act('setstat', { statdisp: 3, alert: ib.alert })}
      />
    );
  });

  return (
    <Stack.Item grow>
      <Section
        fill
        title="Modify Status Screens"
        buttons={<Button icon="arrow-circle-left" content="Back To Main Menu" onClick={() => act('main')} />}
      >
        <LabeledList>
          <LabeledList.Item label="Presets">{presetButtons}</LabeledList.Item>
          <LabeledList.Item label="Alerts">{iconButtons}</LabeledList.Item>
          <LabeledList.Item label="Message Line 1">
            <Button
              icon="pencil-alt"
              content={stat_display.line_1}
              disabled={!authhead}
              onClick={() => act('setmsg1')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Message Line 2">
            <Button
              icon="pencil-alt"
              content={stat_display.line_2}
              disabled={!authhead}
              onClick={() => act('setmsg2')}
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Stack.Item>
  );
};

const MessageView = (props) => {
  const { act, data } = useBackend();

  const { authhead, current_message_title, current_message, messages, security_level } = data;

  let messageView;
  if (current_message_title) {
    messageView = (
      <Stack.Item>
        <Section
          title={current_message_title}
          buttons={
            <Button
              icon="times"
              content="Return To Message List"
              disabled={!authhead}
              onClick={() => act('messagelist')}
            />
          }
        >
          <Box>{current_message}</Box>
        </Section>
      </Stack.Item>
    );
  } else {
    let messageRows = messages.map((m) => {
      return (
        <LabeledList.Item key={m.id} label={m.title}>
          <Button
            icon="eye"
            content="View"
            disabled={!authhead || current_message_title === m.title}
            onClick={() => act('messagelist', { msgid: m.id })}
          />
          <Button.Confirm
            icon="times"
            content="Delete"
            disabled={!authhead}
            onClick={() => act('delmessage', { msgid: m.id })}
          />
        </LabeledList.Item>
      );
    });
    messageView = (
      <Section
        title="Messages Received"
        buttons={<Button icon="arrow-circle-left" content="Back To Main Menu" onClick={() => act('main')} />}
      >
        <LabeledList>{messageRows}</LabeledList>
      </Section>
    );
  }

  return <Box>{messageView}</Box>;
};

const MappedAlertLevelButtons = (props) => {
  const { act, data } = useBackend();

  const { levels, required_access, use_confirm } = props;
  const { security_level } = data;

  if (use_confirm) {
    return levels.map((slevel) => {
      return (
        <Button.Confirm
          key={slevel.name}
          icon={slevel.icon}
          content={slevel.name}
          disabled={!required_access || slevel.id === security_level}
          tooltip={slevel.tooltip}
          onClick={() => act('newalertlevel', { level: slevel.id })}
        />
      );
    });
  }

  return levels.map((slevel) => {
    return (
      <Button
        key={slevel.name}
        icon={slevel.icon}
        content={slevel.name}
        disabled={!required_access || slevel.id === security_level}
        tooltip={slevel.tooltip}
        onClick={() => act('newalertlevel', { level: slevel.id })}
      />
    );
  });
};

const AdminAnnouncePage = (props) => {
  const { act, data } = useBackend();
  const { is_admin, possible_cc_sounds } = data;

  if (!is_admin) {
    return act('main');
  }

  const [subtitle, setSubtitle] = useState('');
  const [text, setText] = useState('');
  const [classified, setClassified] = useState(0);
  const [beepsound, setBeepsound] = useState('Beep');

  return (
    <Stack.Item grow>
      <Section
        fill
        title="Central Command Report"
        buttons={<Button icon="arrow-circle-left" content="Back To Main Menu" onClick={() => act('main')} />}
      >
        <Stack fill vertical>
          <Input fluid placeholder="Enter Subtitle here." value={subtitle} onChange={(value) => setSubtitle(value)} />
          <TextArea
            fluid
            height="100%"
            rows={10}
            placeholder="Enter Announcement here. Multiline input is accepted."
            value={text}
            onChange={setText}
          />
          <Button.Confirm
            fluid
            icon="paper-plane"
            textAlign="center"
            onClick={() => {
              act('make_cc_announcement', {
                subtitle: subtitle,
                text: text,
                classified: classified,
                beepsound: beepsound,
              });
              setText('');
              setSubtitle('');
            }}
          >
            Send Announcement
          </Button.Confirm>
          <Stack align="center">
            <Stack.Item grow>
              <Dropdown
                options={possible_cc_sounds}
                selected={beepsound}
                onSelected={(val) => setBeepsound(val)}
                disabled={classified}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="volume-up"
                disabled={classified}
                tooltip="Test sound"
                onClick={() => act('test_sound', { sound: beepsound })}
              />
            </Stack.Item>
            <Stack.Item>
              <Button.Checkbox
                fluid
                checked={classified}
                tooltip={classified ? 'Sent to station communications consoles' : 'Publically announced'}
                onClick={() => setClassified(!classified)}
              >
                Classified
              </Button.Checkbox>
            </Stack.Item>
          </Stack>
        </Stack>
      </Section>
    </Stack.Item>
  );
};
