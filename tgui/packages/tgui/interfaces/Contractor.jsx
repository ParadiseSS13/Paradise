import { Component, Fragment } from 'react';
import { useState } from 'react';
import { Box, Button, Flex, Icon, LabeledList, Modal, Section, Tabs } from 'tgui-core/components';
import { rad2deg } from 'tgui-core/math';

import { useBackend } from '../backend';
import { Countdown } from '../components';
import { Window } from '../layouts';

const contractStatuses = {
  1: ['ACTIVE', 'good'],
  2: ['COMPLETED', 'good'],
  3: ['FAILED', 'bad'],
};

// Lifted from /tg/station
const terminalMessages = [
  'Recording biometric data...',
  'Analyzing embedded syndicate info...',
  'STATUS CONFIRMED',
  'Contacting Syndicate database...',
  'Awaiting response...',
  'Awaiting response...',
  'Awaiting response...',
  'Awaiting response...',
  'Awaiting response...',
  'Awaiting response...',
  'Response received, ack 4851234...',
  'CONFIRM ACC ' + Math.round(Math.random() * 20000),
  'Setting up private accounts...',
  'CONTRACTOR ACCOUNT CREATED',
  'Searching for available contracts...',
  'Searching for available contracts...',
  'Searching for available contracts...',
  'Searching for available contracts...',
  'CONTRACTS FOUND',
  'WELCOME, AGENT',
];

export const Contractor = (properties) => {
  const { act, data } = useBackend();
  const [viewingPhoto, setViewingPhoto] = useState('');
  let body;
  if (data.unauthorized) {
    body = (
      <Flex.Item grow="1" backgroundColor="rgba(0, 0, 0, 0.8)">
        <FakeTerminal
          height="100%"
          allMessages={['ERROR: UNAUTHORIZED USER']}
          finishedTimeout={100}
          onFinished={() => {}}
        />
      </Flex.Item>
    );
  } else if (!data.load_animation_completed) {
    body = (
      <Flex.Item grow="1" backgroundColor="rgba(0, 0, 0, 0.8)">
        <FakeTerminal
          height="100%"
          allMessages={terminalMessages}
          finishedTimeout={3000}
          onFinished={() => act('complete_load_animation')}
        />
      </Flex.Item>
    );
  } else {
    body = (
      <>
        <Flex.Item basis="content">
          <Summary />
        </Flex.Item>
        <Flex.Item basis="content" mt="0.5rem">
          <Navigation />
        </Flex.Item>
        <Flex.Item grow="1" overflow="hidden">
          {data.page === 1 ? <Contracts height="100%" setViewingPhoto={setViewingPhoto} /> : <Hub height="100%" />}
        </Flex.Item>
      </>
    );
  }
  return (
    <Window theme="syndicate" width={500} height={600}>
      {viewingPhoto && <PhotoZoom viewingPhoto={viewingPhoto} setViewingPhoto={setViewingPhoto} />}
      <Window.Content className="Contractor">
        <Flex direction="column" height="100%">
          {body}
        </Flex>
      </Window.Content>
    </Window>
  );
};

const Summary = (properties) => {
  const { act, data } = useBackend();
  const { tc_available, tc_paid_out, completed_contracts, rep } = data;
  return (
    <Section
      title="Summary"
      buttons={
        <Box verticalAlign="middle" mt="0.25rem">
          {rep} Rep
        </Box>
      }
      {...properties}
    >
      <Flex>
        <Box flexBasis="50%">
          <LabeledList>
            <LabeledList.Item label="TC Available" verticalAlign="middle">
              <Flex align="center">
                <Flex.Item grow="1">{tc_available} TC</Flex.Item>
                <Button
                  disabled={tc_available <= 0}
                  content="Claim"
                  mx="0.75rem"
                  mb="0"
                  flexBasis="content"
                  onClick={() => act('claim')}
                />
              </Flex>
            </LabeledList.Item>
            <LabeledList.Item label="TC Earned">{tc_paid_out} TC</LabeledList.Item>
          </LabeledList>
        </Box>
        <Box flexBasis="50%">
          <LabeledList>
            <LabeledList.Item label="Contracts Completed" verticalAlign="middle">
              <Box height="20px" lineHeight="20px" inline>
                {completed_contracts}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Contractor Status" verticalAlign="middle">
              ACTIVE
            </LabeledList.Item>
          </LabeledList>
        </Box>
      </Flex>
    </Section>
  );
};

const Navigation = (properties) => {
  const { act, data } = useBackend();
  const { page } = data;
  return (
    <Tabs {...properties}>
      <Tabs.Tab
        selected={page === 1}
        onClick={() =>
          act('page', {
            page: 1,
          })
        }
      >
        <Icon name="suitcase" />
        Contracts
      </Tabs.Tab>
      <Tabs.Tab
        selected={page === 2}
        onClick={() =>
          act('page', {
            page: 2,
          })
        }
      >
        <Icon name="shopping-cart" />
        Hub
      </Tabs.Tab>
    </Tabs>
  );
};

const Contracts = (properties) => {
  const { act, data } = useBackend();
  const { contracts, contract_active, can_extract } = data;
  const activeContract = !!contract_active && contracts.filter((c) => c.status === 1)[0];
  const extractionCooldown = activeContract && activeContract.time_left > 0;
  const { setViewingPhoto, ...rest } = properties;
  return (
    <Section
      title="Available Contracts"
      overflow="auto"
      buttons={
        <Button disabled={!can_extract || extractionCooldown} icon="parachute-box" onClick={() => act('extract')}>
          Call Extraction{' '}
          {extractionCooldown && <Countdown timeEnd={activeContract.time_left} format={(v, f) => f.substr(3)} />}
        </Button>
      }
      {...rest}
    >
      {contracts
        .slice()
        .sort((a, b) => {
          if (a.status === 1) {
            return -1;
          } else if (b.status === 1) {
            return 1;
          } else {
            return a.status - b.status;
          }
        })
        .map((contract) => (
          <Section
            key={contract.uid}
            title={
              <Flex>
                <Flex.Item grow="1" color={contract.status === 1 && 'good'}>
                  {contract.target_name}
                </Flex.Item>
                <Flex.Item basis="content">
                  {contract.has_photo && (
                    <Button
                      icon="camera"
                      mb="-0.5rem"
                      ml="0.5rem"
                      onClick={() => setViewingPhoto('target_photo_' + contract.uid + '.png')}
                    />
                  )}
                </Flex.Item>
              </Flex>
            }
            className="Contractor__Contract"
            buttons={
              <Box width="100%">
                {!!contractStatuses[contract.status] && (
                  <Box
                    color={contractStatuses[contract.status][1]}
                    inline
                    mt={contract.status !== 1 && '0.125rem'}
                    mr="0.25rem"
                    lineHeight="20px"
                  >
                    {contractStatuses[contract.status][0]}
                  </Box>
                )}
                {contract.status === 1 && (
                  <Button.Confirm icon="ban" color="bad" content="Abort" ml="0.5rem" onClick={() => act('abort')} />
                )}
              </Box>
            }
          >
            <Flex>
              <Flex.Item grow="2" mr="0.5rem">
                {contract.fluff_message}
                {!!contract.completed_time && (
                  <Box color="good">
                    <br />
                    <Icon name="check" mr="0.5rem" />
                    Contract completed at {contract.completed_time}
                  </Box>
                )}
                {!!contract.dead_extraction && (
                  <Box color="bad" mt="0.5rem" bold>
                    <Icon name="exclamation-triangle" mr="0.5rem" />
                    Telecrystals reward reduced drastically as the target was dead during extraction.
                  </Box>
                )}
                {!!contract.fail_reason && (
                  <Box color="bad">
                    <br />
                    <Icon name="times" mr="0.5rem" />
                    Contract failed: {contract.fail_reason}
                  </Box>
                )}
              </Flex.Item>
              <Flex.Item flexBasis="100%">
                <Flex mb="0.5rem" color="label">
                  Extraction Zone:&nbsp;
                  {areaArrow(contract)}
                </Flex>
                {contract.difficulties?.map((difficulty, key) => (
                  <Button.Confirm
                    key={key}
                    disabled={!!contract_active}
                    content={difficulty.name + ' (' + difficulty.reward + ' TC)'}
                    onClick={() =>
                      act('activate', {
                        uid: contract.uid,
                        difficulty: key + 1,
                      })
                    }
                  />
                ))}
                {!!contract.objective && (
                  <Box color="white" bold>
                    {contract.objective.extraction_name}
                    <br />({(contract.objective.rewards.tc || 0) + ' TC'},&nbsp;
                    {(contract.objective.rewards.credits || 0) + ' Credits'})
                  </Box>
                )}
              </Flex.Item>
            </Flex>
          </Section>
        ))}
    </Section>
  );
};

const areaArrow = (contract) => {
  if (!contract.objective || contract.status > 1) {
    return;
  } else {
    const current_area_id = contract.objective.locs.user_area_id;
    const c_coords = contract.objective.locs.user_coords;
    const target_area_id = contract.objective.locs.target_area_id;
    const t_coords = contract.objective.locs.target_coords;
    const same_area = current_area_id === target_area_id;
    return (
      <Flex.Item>
        <Icon
          name={same_area ? 'dot-circle-o' : 'arrow-alt-circle-right-o'}
          color={same_area ? 'green' : 'yellow'}
          rotation={same_area ? null : -rad2deg(Math.atan2(t_coords[1] - c_coords[1], t_coords[0] - c_coords[0]))}
          lineHeight={same_area ? null : '0.85'} // Needed because it jumps upwards otherwise
          size="1.5"
        />
      </Flex.Item>
    );
  }
};

const Hub = (properties) => {
  const { act, data } = useBackend();
  const { rep, buyables } = data;
  return (
    <Section title="Available Purchases" overflow="auto" {...properties}>
      {buyables.map((buyable) => (
        <Section key={buyable.uid} title={buyable.name}>
          {buyable.description}
          <br />
          <Button.Confirm
            disabled={rep < buyable.cost || buyable.stock === 0}
            icon="shopping-cart"
            content={'Buy (' + buyable.cost + ' Rep)'}
            mt="0.5rem"
            onClick={() =>
              act('purchase', {
                uid: buyable.uid,
              })
            }
          />
          {buyable.stock > -1 && (
            <Box as="span" color={buyable.stock === 0 ? 'bad' : 'good'} ml="0.5rem">
              {buyable.stock} in stock
            </Box>
          )}
        </Section>
      ))}
    </Section>
  );
};

// Lifted from /tg/station
class FakeTerminal extends Component {
  constructor(props) {
    super(props);
    this.timer = null;
    this.state = {
      currentIndex: 0,
      currentDisplay: [],
    };
  }

  tick() {
    const { props, state } = this;
    if (state.currentIndex <= props.allMessages.length) {
      this.setState((prevState) => {
        return {
          currentIndex: prevState.currentIndex + 1,
        };
      });
      const { currentDisplay } = state;
      currentDisplay.push(props.allMessages[state.currentIndex]);
    } else {
      clearTimeout(this.timer);
      setTimeout(props.onFinished, props.finishedTimeout);
    }
  }

  componentDidMount() {
    const { linesPerSecond = 2.5 } = this.props;
    this.timer = setInterval(() => this.tick(), 1000 / linesPerSecond);
  }

  componentWillUnmount() {
    clearTimeout(this.timer);
  }

  render() {
    return (
      <Box m={1}>
        {this.state.currentDisplay.map((value) => (
          <Fragment key={value}>
            {value}
            <br />
          </Fragment>
        ))}
      </Box>
    );
  }
}

const PhotoZoom = (props) => {
  const { viewingPhoto, setViewingPhoto } = props;
  return (
    <Modal className="Contractor__photoZoom">
      <Box as="img" src={viewingPhoto} />
      <Button icon="times" content="Close" color="grey" mt="1rem" onClick={() => setViewingPhoto('')} />
    </Modal>
  );
};
