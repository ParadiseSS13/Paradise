import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, LabeledList, NoticeBox, ProgressBar, Section } from '../components';
import { Window } from '../layouts';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';

export const APC = (props, context) => {
  return (
    <Window>
      <Window.Content>
        <ApcContent />
      </Window.Content>
    </Window>
  );
};

const powerStatusMap = {
  2: {
    color: 'good',
    externalPowerText: 'External Power',
    chargingText: 'Fully Charged',
  },
  1: {
    color: 'average',
    externalPowerText: 'Low External Power',
    chargingText: 'Charging',
  },
  0: {
    color: 'bad',
    externalPowerText: 'No External Power',
    chargingText: 'Not Charging',
  },
};

const malfMap = {
  1: {
    icon: 'terminal',
    content: 'Override Programming',
    action: 'hack',
  },
  2: {
    icon: 'caret-square-down',
    content: 'Shunt Core Process',
    action: 'occupy',
  },
  3: {
    icon: 'caret-square-left',
    content: 'Return to Main Core',
    action: 'deoccupy',
  },
  4: {
    icon: 'caret-square-down',
    content: 'Shunt Core Process',
    action: 'occupy',
  },
};

const ApcContent = (props, context) => {
  const { act, data } = useBackend(context);
  const locked = data.locked && !data.siliconUser;
  const normallyLocked = data.normallyLocked;
  const externalPowerStatus = powerStatusMap[data.externalPower]
    || powerStatusMap[0];
  const chargingStatus = powerStatusMap[data.chargingStatus]
    || powerStatusMap[0];
  const channelArray = data.powerChannels || [];
  const malfStatus = malfMap[data.malfStatus] || malfMap[0];
  const adjustedCellChange = data.powerCellStatus / 100;

  return (
    <Fragment>
      <InterfaceLockNoticeBox />
      <Section title="Power Status">
        <LabeledList>
          <LabeledList.Item
            label="Main Breaker"
            color={externalPowerStatus.color}
            buttons={(
              <Button
                icon={data.isOperating ? 'power-off' : 'times'}
                content={data.isOperating ? 'On' : 'Off'}
                selected={data.isOperating && !locked}
                color={data.isOperating ? "" : "bad"}
                disabled={locked}
                onClick={() => act('breaker')} />
            )}>
            [ {externalPowerStatus.externalPowerText} ]
          </LabeledList.Item>
          <LabeledList.Item label="Power Cell">
            <ProgressBar
              color="good"
              value={adjustedCellChange} />
          </LabeledList.Item>
          <LabeledList.Item
            label="Charge Mode"
            color={chargingStatus.color}
            buttons={(
              <Button
                icon={data.chargeMode ? 'sync' : 'times'}
                content={data.chargeMode ? 'Auto' : 'Off'}
                selected={data.chargeMode}
                disabled={locked}
                onClick={() => act('charge')} />
            )}>
            [ {chargingStatus.chargingText} ]
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Power Channels">
        <LabeledList>
          {channelArray.map(channel => {
            const { topicParams } = channel;
            return (
              <LabeledList.Item
                key={channel.title}
                label={channel.title}
                buttons={(
                  <Fragment>
                    <Box inline mx={2}
                      color={channel.status >= 2 ? 'good' : 'bad'}>
                      {channel.status >= 2 ? 'On' : 'Off'}
                    </Box>
                    <Button
                      icon="sync"
                      content="Auto"
                      selected={!locked && (
                        channel.status === 1 || channel.status === 3
                      )}
                      disabled={locked}
                      onClick={() => act('channel', topicParams.auto)} />
                    <Button
                      icon="power-off"
                      content="On"
                      selected={!locked && channel.status === 2}
                      disabled={locked}
                      onClick={() => act('channel', topicParams.on)} />
                    <Button
                      icon="times"
                      content="Off"
                      selected={!locked && channel.status === 0}
                      disabled={locked}
                      onClick={() => act('channel', topicParams.off)} />
                  </Fragment>
                )}>
                {channel.powerLoad} W
              </LabeledList.Item>
            );
          })}
          <LabeledList.Item label="Total Load">
            <b>{data.totalLoad} W</b>
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section
        title="Misc"
        buttons={!!data.siliconUser && (
          <Fragment>
            {!!data.malfStatus && (
              <Button
                icon={malfStatus.icon}
                content={malfStatus.content}
                color="bad"
                onClick={() => act(malfStatus.action)} />
            )}
            <Button
              icon="lightbulb-o"
              content="Overload"
              onClick={() => act('overload')} />
          </Fragment>
        )}>
        <LabeledList>
          <LabeledList.Item
            label="Cover Lock"
            buttons={(
              <Button
                icon={data.coverLocked ? 'lock' : 'unlock'}
                content={data.coverLocked ? 'Engaged' : 'Disengaged'}
                selected={data.coverLocked}
                disabled={locked}
                onClick={() => act('cover')} />
            )} />
          <LabeledList.Item
            label="Night Shift Lighting"
            buttons={(
              <Button
                icon="lightbulb-o"
                content={data.nightshiftLights ? 'Enabled' : 'Disabled'}
                selected={data.nightshiftLights}
                onClick={() => act('toggle_nightshift')} />
            )} />
        </LabeledList>
      </Section>
    </Fragment>
  );
};
