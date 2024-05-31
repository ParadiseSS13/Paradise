import { classes } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Divider,
  Dropdown,
  Icon,
  Input,
  LabeledList,
  Modal,
  Section,
  Stack,
} from '../components';
import { timeAgo } from '../constants';
import { Window } from '../layouts';
import {
  ComplexModal,
  modalAnswer,
  modalClose,
  modalOpen,
  modalRegisterBodyOverride,
} from './common/ComplexModal';
import { TemporaryNotice } from './common/TemporaryNotice';

const HEADLINE_MAX_LENGTH = 128;

const jobOpeningCategoriesOrder = [
  'security',
  'engineering',
  'medical',
  'science',
  'service',
  'supply',
];
const jobOpeningCategories = {
  security: {
    title: 'Security',
    fluff_text: 'Help keep the crew safe',
  },
  engineering: {
    title: 'Engineering',
    fluff_text: 'Ensure the station runs smoothly',
  },
  medical: {
    title: 'Medical',
    fluff_text: 'Practice medicine and save lives',
  },
  science: {
    title: 'Science',
    fluff_text: 'Develop new technologies',
  },
  service: {
    title: 'Service',
    fluff_text: 'Provide amenities to the crew',
  },
  supply: {
    title: 'Supply',
    fluff_text: 'Keep the station supplied',
  },
};

export const Newscaster = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    is_security,
    is_admin,
    is_silent,
    is_printing,
    screen,
    channels,
    channel_idx = -1,
  } = data;
  const [menuOpen, setMenuOpen] = useLocalState(context, 'menuOpen', false);
  const [viewingPhoto, _setViewingPhoto] = useLocalState(
    context,
    'viewingPhoto',
    ''
  );
  const [censorMode, setCensorMode] = useLocalState(
    context,
    'censorMode',
    false
  );
  let body;
  if (screen === 0 || screen === 2) {
    body = <NewscasterFeed />;
  } else if (screen === 1) {
    body = <NewscasterJobs />;
  }
  const totalUnread = channels.reduce((a, c) => a + c.unread, 0);
  return (
    <Window theme={is_security && 'security'} width={800} height={600}>
      {viewingPhoto ? (
        <PhotoZoom />
      ) : (
        <ComplexModal
          maxWidth={window.innerWidth / 1.5 + 'px'}
          maxHeight={window.innerHeight / 1.5 + 'px'}
        />
      )}
      <Window.Content>
        <Stack fill>
          <Section
            fill
            className={classes([
              'Newscaster__menu',
              menuOpen && 'Newscaster__menu--open',
            ])}
          >
            <Stack fill vertical>
              <Stack.Item>
                <MenuButton
                  icon="bars"
                  title="Toggle Menu"
                  onClick={() => setMenuOpen(!menuOpen)}
                />
                <MenuButton
                  icon="newspaper"
                  title="Headlines"
                  selected={screen === 0}
                  onClick={() => act('headlines')}
                >
                  {totalUnread > 0 && (
                    <Box className="Newscaster__menuButton--unread">
                      {totalUnread >= 10 ? '9+' : totalUnread}
                    </Box>
                  )}
                </MenuButton>
                <MenuButton
                  icon="briefcase"
                  title="Job Openings"
                  selected={screen === 1}
                  onClick={() => act('jobs')}
                />
                <Divider />
              </Stack.Item>
              <Stack.Item grow>
                {channels.map((channel) => (
                  <MenuButton
                    key={channel}
                    icon={channel.icon}
                    title={channel.name}
                    selected={
                      screen === 2 && channels[channel_idx - 1] === channel
                    }
                    onClick={() => act('channel', { uid: channel.uid })}
                  >
                    {channel.unread > 0 && (
                      <Box className="Newscaster__menuButton--unread">
                        {channel.unread >= 10 ? '9+' : channel.unread}
                      </Box>
                    )}
                  </MenuButton>
                ))}
              </Stack.Item>
              <Stack.Item>
                <Divider />
                {(!!is_security || !!is_admin) && (
                  <>
                    <MenuButton
                      security
                      icon="exclamation-circle"
                      title="Edit Wanted Notice"
                      mb="0.5rem"
                      onClick={() => modalOpen(context, 'wanted_notice')}
                    />
                    <MenuButton
                      security
                      icon={censorMode ? 'minus-square' : 'minus-square-o'}
                      title={'Censor Mode: ' + (censorMode ? 'On' : 'Off')}
                      mb="0.5rem"
                      onClick={() => setCensorMode(!censorMode)}
                    />
                    <Divider />
                  </>
                )}
                <MenuButton
                  icon="pen-alt"
                  title="New Story"
                  mb="0.5rem"
                  onClick={() => modalOpen(context, 'create_story')}
                />
                <MenuButton
                  icon="plus-circle"
                  title="New Channel"
                  onClick={() => modalOpen(context, 'create_channel')}
                />
                <Divider />
                <MenuButton
                  icon={is_printing ? 'spinner' : 'print'}
                  iconSpin={is_printing}
                  title={is_printing ? 'Printing...' : 'Print Newspaper'}
                  onClick={() => act('print_newspaper')}
                />
                <MenuButton
                  icon={is_silent ? 'volume-mute' : 'volume-up'}
                  title={'Mute: ' + (is_silent ? 'On' : 'Off')}
                  onClick={() => act('toggle_mute')}
                />
              </Stack.Item>
            </Stack>
          </Section>
          <Stack fill vertical width="100%">
            <TemporaryNotice />
            {body}
          </Stack>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MenuButton = (properties, context) => {
  const { act } = useBackend(context);
  const {
    icon = '',
    iconSpin,
    selected = false,
    security = false,
    onClick,
    title,
    children,
    ...rest
  } = properties;
  return (
    <Box
      className={classes([
        'Newscaster__menuButton',
        selected && 'Newscaster__menuButton--selected',
        security && 'Newscaster__menuButton--security',
      ])}
      onClick={onClick}
      {...rest}
    >
      {selected && <Box className="Newscaster__menuButton--selectedBar" />}
      <Icon name={icon} spin={iconSpin} size="2" />
      <Box className="Newscaster__menuButton--title">{title}</Box>
      {children}
    </Box>
  );
};

const NewscasterFeed = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    screen,
    is_admin,
    channel_idx,
    channel_can_manage,
    channels,
    stories,
    wanted,
  } = data;
  const [fullStories, _setFullStories] = useLocalState(
    context,
    'fullStories',
    []
  );
  const [censorMode, _setCensorMode] = useLocalState(
    context,
    'censorMode',
    false
  );
  const channel =
    screen === 2 && channel_idx > -1 ? channels[channel_idx - 1] : null;
  return (
    <Stack fill vertical>
      {!!wanted && <Story story={wanted} wanted />}
      <Section
        fill
        scrollable
        title={
          <>
            <Icon name={channel ? channel.icon : 'newspaper'} mr="0.5rem" />
            {channel ? channel.name : 'Headlines'}
          </>
        }
      >
        {stories.length > 0 ? (
          stories
            .slice()
            .reverse()
            .map((story) =>
              !fullStories.includes(story.uid) &&
              story.body.length + 3 > HEADLINE_MAX_LENGTH
                ? {
                    ...story,
                    body_short:
                      story.body.substr(0, HEADLINE_MAX_LENGTH - 4) + '...',
                  }
                : story
            )
            .map((story, index) => <Story key={index} story={story} />)
        ) : (
          <Box className="Newscaster__emptyNotice">
            <Icon name="times" size="3" />
            <br />
            There are no stories at this time.
          </Box>
        )}
      </Section>
      {!!channel && (
        <Section
          fill
          scrollable
          height="40%"
          title={
            <>
              <Icon name="info-circle" mr="0.5rem" />
              About
            </>
          }
          buttons={
            <>
              {censorMode && (
                <Button
                  disabled={!!channel.admin && !is_admin}
                  selected={channel.censored}
                  icon={channel.censored ? 'comment-slash' : 'comment'}
                  content={
                    channel.censored ? 'Uncensor Channel' : 'Censor Channel'
                  }
                  mr="0.5rem"
                  onClick={() => act('censor_channel', { uid: channel.uid })}
                />
              )}
              <Button
                disabled={!channel_can_manage}
                icon="cog"
                content="Manage"
                onClick={() =>
                  modalOpen(context, 'manage_channel', {
                    uid: channel.uid,
                  })
                }
              />
            </>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Description">
              {channel.description || 'N/A'}
            </LabeledList.Item>
            <LabeledList.Item label="Owner">
              {channel.author || 'N/A'}
            </LabeledList.Item>
            {!!is_admin && (
              <LabeledList.Item label="Ckey">
                {channel.author_ckey}
              </LabeledList.Item>
            )}
            <LabeledList.Item label="Public">
              {channel.public ? 'Yes' : 'No'}
            </LabeledList.Item>
            <LabeledList.Item label="Total Views">
              <Icon name="eye" mr="0.5rem" />
              {stories.reduce((a, c) => a + c.view_count, 0).toLocaleString()}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      )}
    </Stack>
  );
};

const NewscasterJobs = (properties, context) => {
  const { act, data } = useBackend(context);
  const { jobs, wanted } = data;
  const numOpenings = Object.entries(jobs).reduce(
    (a, [k, v]) => a + v.length,
    0
  );
  return (
    <Stack fill vertical>
      {!!wanted && <Story story={wanted} wanted />}
      <Section
        fill
        scrollable
        title={
          <>
            <Icon name="briefcase" mr="0.5rem" />
            Job Openings
          </>
        }
        buttons={
          <Box mt="0.25rem" color="label">
            Work for a better future at Nanotrasen
          </Box>
        }
      >
        {numOpenings > 0 ? (
          jobOpeningCategoriesOrder
            .map((catId) =>
              Object.assign({}, jobOpeningCategories[catId], {
                id: catId,
                jobs: jobs[catId],
              })
            )
            .filter((cat) => !!cat && cat.jobs.length > 0)
            .map((cat) => (
              <Section
                key={cat.id}
                className={classes([
                  'Newscaster__jobCategory',
                  'Newscaster__jobCategory--' + cat.id,
                ])}
                title={cat.title}
                buttons={
                  <Box mt="0.25rem" color="label">
                    {cat.fluff_text}
                  </Box>
                }
              >
                {cat.jobs.map((job) => (
                  <Box
                    key={job.title}
                    class={classes([
                      'Newscaster__jobOpening',
                      !!job.is_command && 'Newscaster__jobOpening--command',
                    ])}
                  >
                    • {job.title}
                  </Box>
                ))}
              </Section>
            ))
        ) : (
          <Box className="Newscaster__emptyNotice">
            <Icon name="times" size="3" />
            <br />
            There are no openings at this time.
          </Box>
        )}
      </Section>
      <Section height="17%">
        Interested in serving Nanotrasen?
        <br />
        Sign up for any of the above position now at the{' '}
        <b>Head of Personnel&apos;s Office!</b>
        <br />
        <Box as="small" color="label">
          By signing up for a job at Nanotrasen, you agree to transfer your soul
          to the loyalty department of the omnipresent and helpful watcher of
          humanity.
        </Box>
      </Section>
    </Stack>
  );
};

const Story = (properties, context) => {
  const { act, data } = useBackend(context);
  const { story, wanted = false } = properties;
  const { is_admin } = data;
  const [fullStories, setFullStories] = useLocalState(
    context,
    'fullStories',
    []
  );
  const [censorMode, _setCensorMode] = useLocalState(
    context,
    'censorMode',
    false
  );
  return (
    <Section
      className={classes([
        'Newscaster__story',
        wanted && 'Newscaster__story--wanted',
      ])}
      title={
        <>
          {wanted && <Icon name="exclamation-circle" mr="0.5rem" />}
          {(story.censor_flags & 2 && '[REDACTED]') ||
            story.title ||
            'News from ' + story.author}
        </>
      }
      buttons={
        <Box mt="0.25rem">
          <Box color="label">
            {!wanted && censorMode && (
              <Box inline>
                <Button
                  enabled={story.censor_flags & 2}
                  icon={story.censor_flags & 2 ? 'comment-slash' : 'comment'}
                  content={story.censor_flags & 2 ? 'Uncensor' : 'Censor'}
                  mr="0.5rem"
                  mt="-0.25rem"
                  onClick={() => act('censor_story', { uid: story.uid })}
                />
              </Box>
            )}
            <Box inline>
              <Icon name="user" /> {story.author} |&nbsp;
              {!!is_admin && <>ckey: {story.author_ckey} |&nbsp;</>}
              {!wanted && (
                <>
                  <Icon name="eye" /> {story.view_count.toLocaleString()}{' '}
                  |&nbsp;
                </>
              )}
              <Icon name="clock" />{' '}
              {timeAgo(story.publish_time, data.world_time)}
            </Box>
          </Box>
        </Box>
      }
    >
      <Box>
        {story.censor_flags & 2 ? (
          '[REDACTED]'
        ) : (
          <>
            {!!story.has_photo && (
              <PhotoThumbnail
                name={'story_photo_' + story.uid + '.png'}
                float="right"
                ml="0.5rem"
              />
            )}
            {(story.body_short || story.body).split('\n').map((p, index) => (
              <Box key={index}>{p || <br />}</Box>
            ))}
            {story.body_short && (
              <Button
                content="Read more.."
                mt="0.5rem"
                onClick={() => setFullStories([...fullStories, story.uid])}
              />
            )}
            <Box clear="right" />
          </>
        )}
      </Box>
    </Section>
  );
};

const PhotoThumbnail = (properties, context) => {
  const { name, ...rest } = properties;
  const [viewingPhoto, setViewingPhoto] = useLocalState(
    context,
    'viewingPhoto',
    ''
  );
  return (
    <Box
      as="img"
      className="Newscaster__photo"
      src={name}
      onClick={() => setViewingPhoto(name)}
      {...rest}
    />
  );
};

const PhotoZoom = (properties, context) => {
  const [viewingPhoto, setViewingPhoto] = useLocalState(
    context,
    'viewingPhoto',
    ''
  );
  return (
    <Modal className="Newscaster__photoZoom">
      <Box as="img" src={viewingPhoto} />
      <Button
        icon="times"
        content="Close"
        color="grey"
        mt="1rem"
        onClick={() => setViewingPhoto('')}
      />
    </Modal>
  );
};

// This handles both creation and editing
const manageChannelModalBodyOverride = (modal, context) => {
  const { act, data } = useBackend(context);
  // Additional data
  const channel =
    !!modal.args.uid &&
    data.channels.filter((c) => c.uid === modal.args.uid).pop();
  if (modal.id === 'manage_channel' && !channel) {
    modalClose(context); // ?
    return;
  }
  const isEditing = modal.id === 'manage_channel';
  const isAdmin = !!modal.args.is_admin;
  const scannedUser = modal.args.scanned_user;
  // Temp data
  const [author, setAuthor] = useLocalState(
    context,
    'author',
    channel?.author || scannedUser || 'Unknown'
  );
  const [name, setName] = useLocalState(context, 'name', channel?.name || '');
  const [description, setDescription] = useLocalState(
    context,
    'description',
    channel?.description || ''
  );
  const [icon, setIcon] = useLocalState(
    context,
    'icon',
    channel?.icon || 'newspaper'
  );
  const [isPublic, setIsPublic] = useLocalState(
    context,
    'isPublic',
    isEditing ? !!channel?.public : false
  );
  const [adminLocked, setAdminLocked] = useLocalState(
    context,
    'adminLocked',
    channel?.admin === 1 || false
  );
  return (
    <Section
      m="-1rem"
      pb="1.5rem"
      title={isEditing ? 'Manage ' + channel.name : 'Create New Channel'}
    >
      <Box mx="0.5rem">
        <LabeledList>
          <LabeledList.Item label="Owner">
            <Input
              disabled={!isAdmin}
              width="100%"
              value={author}
              onInput={(_e, v) => setAuthor(v)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Name">
            <Input
              width="100%"
              placeholder="50 characters max."
              maxLength="50"
              value={name}
              onInput={(_e, v) => setName(v)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Description (optional)" verticalAlign="top">
            <Input
              multiline
              width="100%"
              placeholder="128 characters max."
              maxLength="128"
              value={description}
              onInput={(_e, v) => setDescription(v)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Icon">
            <Input
              disabled={!isAdmin}
              value={icon}
              width="35%"
              mr="0.5rem"
              onInput={(_e, v) => setIcon(v)}
            />
            <Icon name={icon} size="2" verticalAlign="middle" mr="0.5rem" />
          </LabeledList.Item>
          <LabeledList.Item label="Accept Public Stories?">
            <Button
              selected={isPublic}
              icon={isPublic ? 'toggle-on' : 'toggle-off'}
              content={isPublic ? 'Yes' : 'No'}
              onClick={() => setIsPublic(!isPublic)}
            />
          </LabeledList.Item>
          {isAdmin && (
            <LabeledList.Item label="CentComm Lock" verticalAlign="top">
              <Button
                selected={adminLocked}
                icon={adminLocked ? 'lock' : 'lock-open'}
                content={adminLocked ? 'On' : 'Off'}
                tooltip="Locking this channel will make it editable by nobody but CentComm officers."
                tooltipPosition="top"
                onClick={() => setAdminLocked(!adminLocked)}
              />
            </LabeledList.Item>
          )}
        </LabeledList>
      </Box>
      <Button.Confirm
        disabled={author.trim().length === 0 || name.trim().length === 0}
        icon="check"
        color="good"
        content="Submit"
        position="absolute"
        right="1rem"
        bottom="-0.75rem"
        onClick={() => {
          modalAnswer(context, modal.id, '', {
            author: author,
            name: name.substr(0, 49),
            description: description.substr(0, 128),
            icon: icon,
            public: isPublic ? 1 : 0,
            admin_locked: adminLocked ? 1 : 0,
          });
        }}
      />
    </Section>
  );
};

const createStoryModalBodyOverride = (modal, context) => {
  const { act, data } = useBackend(context);
  const { photo, channels, channel_idx = -1 } = data;
  // Additional data
  const isAdmin = !!modal.args.is_admin;
  const scannedUser = modal.args.scanned_user;
  let availableChannels = channels
    .slice()
    .sort((a, b) => {
      if (channel_idx < 0) {
        return 0;
      }
      const selected = channels[channel_idx - 1];
      if (selected.uid === a.uid) {
        return -1;
      } else if (selected.uid === b.uid) {
        return 1;
      }
    })
    .filter(
      (c) => isAdmin || (!c.frozen && (c.author === scannedUser || !!c.public))
    );
  // Temp data
  const [author, setAuthor] = useLocalState(
    context,
    'author',
    scannedUser || 'Unknown'
  );
  const [channel, setChannel] = useLocalState(
    context,
    'channel',
    availableChannels.length > 0 ? availableChannels[0].name : ''
  );
  const [title, setTitle] = useLocalState(context, 'title', '');
  const [body, setBody] = useLocalState(context, 'body', '');
  const [adminLocked, setAdminLocked] = useLocalState(
    context,
    'adminLocked',
    false
  );
  return (
    <Section m="-1rem" pb="1.5rem" title="Create New Story">
      <Box mx="0.5rem">
        <LabeledList>
          <LabeledList.Item label="Author">
            <Input
              disabled={!isAdmin}
              width="100%"
              value={author}
              onInput={(_e, v) => setAuthor(v)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Channel" verticalAlign="top">
            <Dropdown
              selected={channel}
              options={availableChannels.map((c) => c.name)}
              mb="0"
              width="100%"
              onSelected={(c) => setChannel(c)}
            />
          </LabeledList.Item>
          <LabeledList.Divider />
          <LabeledList.Item label="Title">
            <Input
              width="100%"
              placeholder="128 characters max."
              maxLength="128"
              value={title}
              onInput={(_e, v) => setTitle(v)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Story Text" verticalAlign="top">
            <Input
              fluid
              multiline
              placeholder="1024 characters max."
              maxLength="1024"
              rows="8"
              width="100%"
              value={body}
              onInput={(_e, v) => setBody(v)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Photo (optional)" verticalAlign="top">
            <Button
              icon="image"
              selected={photo}
              content={photo ? 'Eject: ' + photo.name : 'Insert Photo'}
              tooltip={
                !photo &&
                'Attach a photo to this story by holding the photograph in your hand.'
              }
              onClick={() => act(photo ? 'eject_photo' : 'attach_photo')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Preview" verticalAlign="top">
            <Section
              noTopPadding
              title={title}
              maxHeight="13.5rem"
              overflow="auto"
            >
              <Box mt="0.5rem">
                {!!photo && (
                  <PhotoThumbnail
                    name={'inserted_photo_' + photo.uid + '.png'}
                    float="right"
                  />
                )}
                {body.split('\n').map((p, index) => (
                  <Box key={index}>{p || <br />}</Box>
                ))}
                <Box clear="right" />
              </Box>
            </Section>
          </LabeledList.Item>
          {isAdmin && (
            <LabeledList.Item label="CentComm Lock" verticalAlign="top">
              <Button
                selected={adminLocked}
                icon={adminLocked ? 'lock' : 'lock-open'}
                content={adminLocked ? 'On' : 'Off'}
                tooltip="Locking this story will make it censorable by nobody but CentComm officers."
                tooltipPosition="top"
                onClick={() => setAdminLocked(!adminLocked)}
              />
            </LabeledList.Item>
          )}
        </LabeledList>
      </Box>
      <Button.Confirm
        disabled={
          author.trim().length === 0 ||
          channel.trim().length === 0 ||
          title.trim().length === 0 ||
          body.trim().length === 0
        }
        icon="check"
        color="good"
        content="Submit"
        position="absolute"
        right="1rem"
        bottom="-0.75rem"
        onClick={() => {
          modalAnswer(context, 'create_story', '', {
            author: author,
            channel: channel,
            title: title.substr(0, 127),
            body: body.substr(0, 1023),
            admin_locked: adminLocked ? 1 : 0,
          });
        }}
      />
    </Section>
  );
};

const wantedNoticeModalBodyOverride = (modal, context) => {
  const { act, data } = useBackend(context);
  const { photo, wanted } = data;
  // Additional data
  const isAdmin = !!modal.args.is_admin;
  const scannedUser = modal.args.scanned_user;
  // Temp data
  const [author, setAuthor] = useLocalState(
    context,
    'author',
    wanted?.author || scannedUser || 'Unknown'
  );
  const [name, setName] = useLocalState(
    context,
    'name',
    wanted?.title.substr(8) || ''
  );
  const [description, setDescription] = useLocalState(
    context,
    'description',
    wanted?.body || ''
  );
  const [adminLocked, setAdminLocked] = useLocalState(
    context,
    'adminLocked',
    wanted?.admin_locked === 1 || false
  );
  return (
    <Section m="-1rem" pb="1.5rem" title="Manage Wanted Notice">
      <Box mx="0.5rem">
        <LabeledList>
          <LabeledList.Item label="Authority">
            <Input
              disabled={!isAdmin}
              width="100%"
              value={author}
              onInput={(_e, v) => setAuthor(v)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Name">
            <Input
              width="100%"
              value={name}
              maxLength="128"
              onInput={(_e, v) => setName(v)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Description" verticalAlign="top">
            <Input
              multiline
              width="100%"
              value={description}
              maxLength="512"
              rows="4"
              onInput={(_e, v) => setDescription(v)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Photo (optional)" verticalAlign="top">
            <Button
              icon="image"
              selected={photo}
              content={photo ? 'Eject: ' + photo.name : 'Insert Photo'}
              tooltip={
                !photo &&
                'Attach a photo to this wanted notice by holding the photograph in your hand.'
              }
              tooltipPosition="top"
              onClick={() => act(photo ? 'eject_photo' : 'attach_photo')}
            />
            {!!photo && (
              <PhotoThumbnail
                name={'inserted_photo_' + photo.uid + '.png'}
                float="right"
              />
            )}
          </LabeledList.Item>
          {isAdmin && (
            <LabeledList.Item label="CentComm Lock" verticalAlign="top">
              <Button
                selected={adminLocked}
                icon={adminLocked ? 'lock' : 'lock-open'}
                content={adminLocked ? 'On' : 'Off'}
                tooltip="Locking this wanted notice will make it editable by nobody but CentComm officers."
                tooltipPosition="top"
                onClick={() => setAdminLocked(!adminLocked)}
              />
            </LabeledList.Item>
          )}
        </LabeledList>
      </Box>
      <Button.Confirm
        disabled={!wanted}
        icon="eraser"
        color="danger"
        content="Clear"
        position="absolute"
        right="7.25rem"
        bottom="-0.75rem"
        onClick={() => {
          act('clear_wanted_notice');
          modalClose(context);
        }}
      />
      <Button.Confirm
        disabled={
          author.trim().length === 0 ||
          name.trim().length === 0 ||
          description.trim().length === 0
        }
        icon="check"
        color="good"
        content="Submit"
        position="absolute"
        right="1rem"
        bottom="-0.75rem"
        onClick={() => {
          modalAnswer(context, modal.id, '', {
            author: author,
            name: name.substr(0, 127),
            description: description.substr(0, 511),
            admin_locked: adminLocked ? 1 : 0,
          });
        }}
      />
    </Section>
  );
};

modalRegisterBodyOverride('create_channel', manageChannelModalBodyOverride);
modalRegisterBodyOverride('manage_channel', manageChannelModalBodyOverride);
modalRegisterBodyOverride('create_story', createStoryModalBodyOverride);
modalRegisterBodyOverride('wanted_notice', wantedNoticeModalBodyOverride);
