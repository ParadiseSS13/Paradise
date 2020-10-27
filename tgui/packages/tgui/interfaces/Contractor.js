import { Component, Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Icon, LabeledList, Modal, Section, Tabs } from '../components';
import { Countdown } from '../components/Countdown';
import { Window } from '../layouts';

const contractStatuses = {
  1: ["ACTIVE", "good"],
  2: ["COMPLETED", "good"],
  3: ["FAILED", "bad"],
};

// Lifted from /tg/station
const terminalMessages = [
  "Recording biometric data...",
  "Analyzing embedded syndicate info...",
  "STATUS CONFIRMED",
  "Contacting Syndicate database...",
  "Awaiting response...",
  "Awaiting response...",
  "Awaiting response...",
  "Awaiting response...",
  "Awaiting response...",
  "Awaiting response...",
  "Response received, ack 4851234...",
  "CONFIRM ACC " + (Math.round(Math.random() * 20000)),
  "Setting up private accounts...",
  "CONTRACTOR ACCOUNT CREATED",
  "Searching for available contracts...",
  "Searching for available contracts...",
  "Searching for available contracts...",
  "Searching for available contracts...",
  "CONTRACTS FOUND",
  "WELCOME, AGENT",
];

export const Contractor = (properties, context) => {
  const { act, data } = useBackend(context);
  let body;
  if (data.unauthorized) {
    body = (
      <Flex.Item grow="1" backgroundColor="rgba(0, 0, 0, 0.8)">
        <FakeTerminal
          height="100%"
          allMessages={["ERROR: UNAUTHORIZED USER"]}
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
      <Fragment>
        <Flex.Item basis="content">
          <Summary />
        </Flex.Item>
        <Flex.Item basis="content" mt="0.5rem">
          <Navigation />
        </Flex.Item>
        <Flex.Item grow="1" overflow="hidden">
          {data.page === 1 ? (
            <Contracts height="100%" />
          ) : (
            <Hub height="100%" />
          )}
        </Flex.Item>
      </Fragment>
    );
  }
  const [viewingPhoto, _setViewingPhoto] = useLocalState(context, "viewingPhoto", "");
  return (
    <Window theme="syndicate">
      {viewingPhoto && (
        <PhotoZoom />
      )}
      <Window.Content className="Contractor">
        <Flex direction="column" height="100%">
          {body}
        </Flex>
      </Window.Content>
    </Window>
  );
};

const Summary = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    tc_available,
    tc_paid_out,
    completed_contracts,
    rep,
  } = data;
  return (
    <Section
      title="Summary"
      buttons={
        <Box verticalAlign="middle" mt="0.25rem">
          {rep} Rep
        </Box>
      }
      {...properties}>
      <Flex>
        <Box flexBasis="50%">
          <LabeledList>
            <LabeledList.Item label="TC Available" verticalAlign="middle">
              <Flex align="center">
                <Flex.Item grow="1">
                  {tc_available} TC
                </Flex.Item>
                <Button
                  disabled={tc_available <= 0}
                  content="Claim"
                  mx="0.75rem"
                  mb="0"
                  flexBasis="content"
                  onClick={() => act("claim")}
                />
              </Flex>
            </LabeledList.Item>
            <LabeledList.Item label="TC Earned">
              {tc_paid_out} TC
            </LabeledList.Item>
          </LabeledList>
        </Box>
        <Box flexBasis="50%">
          <LabeledList>
            <LabeledList.Item label="Contracts Completed" verticalAlign="middle">
              <Box height="20px" lineHeight="20px" display="inline-block">
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

const Navigation = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    page,
  } = data;
  return (
    <Tabs {...properties}>
      <Tabs.Tab
        selected={page === 1}
        onClick={() => act("page", {
          page: 1,
        })}>
        <Icon name="suitcase" />
        Contracts
      </Tabs.Tab>
      <Tabs.Tab
        selected={page === 2}
        onClick={() => act("page", {
          page: 2,
        })}>
        <Icon name="shopping-cart" />
        Hub
      </Tabs.Tab>
    </Tabs>
  );
};

const Contracts = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    contracts,
    contract_active,
    can_extract,
  } = data;
  const activeContract = !!contract_active && contracts.filter(c => c.status === 1)[0];
  const extractionCooldown = activeContract && activeContract.time_left > 0;
  const [_viewingPhoto, setViewingPhoto] = useLocalState(context, "viewingPhoto", "");
  return (
    <Section
      title="Available Contracts"
      overflow="auto"
      buttons={
        <Button
          disabled={!can_extract || extractionCooldown}
          icon="parachute-box"
          content={[
            "Call Extraction",
            extractionCooldown && (
              <Countdown
                timeLeft={activeContract.time_left}
                format={(v, f) => " (" + f.substr(3) + ")"}
              />
            ),
          ]}
          onClick={() => act("extract")}
        />
      }
      {...properties}>
      {contracts.slice().sort((a, b) => {
        if (a.status === 1) {
          return -1;
        } else if (b.status === 1) {
          return 1;
        } else {
          return a.status - b.status;
        }
      }).map(contract => (
        <Section
          key={contract.uid}
          title={(
            <Flex>
              <Flex.Item grow="1" color={contract.status === 1 && "good"}>
                {contract.target_name}
              </Flex.Item>
              <Flex.Item basis="content">
                {contract.has_photo && (
                  <Button
                    icon="camera"
                    mb="-0.5rem"
                    ml="0.5rem"
                    onClick={() => setViewingPhoto("target_photo_" + contract.uid + ".png")}
                  />
                )}
              </Flex.Item>
            </Flex>
          )}
          className="Contractor__Contract"
          buttons={(
            <Box width="100%">
              {!!contractStatuses[contract.status] && (
                <Box
                  color={contractStatuses[contract.status][1]}
                  display="inline-block"
                  mt={contract.status !== 1 && "0.125rem"}
                  mr="0.25rem"
                  lineHeight="20px">
                  {contractStatuses[contract.status][0]}
                </Box>
              )}
              {contract.status === 1 && (
                <Button.Confirm
                  icon="ban"
                  color="bad"
                  content="Abort"
                  ml="0.5rem"
                  onClick={() => act("abort")}
                />
              )}
            </Box>
          )}>
          <Flex width="100%">
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
            <Flex.Item grow="1" flexBasis="100%">
              <Box mb="0.5rem" color="label">
                Extraction Zone:
              </Box>
              {contract.difficulties?.map((difficulty, key) => (
                <Fragment>
                  <Button.Confirm
                    disabled={!!contract_active}
                    content={difficulty.name + " (" + difficulty.reward + " TC)"}
                    onClick={() => act("activate", {
                      uid: contract.uid,
                      difficulty: key + 1,
                    })}
                  />
                  <br />
                </Fragment>
              ))}
              {!!contract.objective && (
                <Box color="white" bold>
                  {contract.objective.extraction_zone}<br />
                  ({(contract.objective.reward_tc || 0) + " TC"},&nbsp;
                  {(contract.objective.reward_credits || 0) + " Credits"})
                </Box>
              )}
            </Flex.Item>
          </Flex>
        </Section>
      ))}
    </Section>
  );
};

const Hub = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    rep,
    buyables,
  } = data;
  return (
    <Section
      title="Available Purchases"
      overflow="auto"
      {...properties}>
      {buyables.map(buyable => (
        <Section
          key={buyable.uid}
          title={buyable.name}>
          {buyable.description}<br />
          <Button.Confirm
            disabled={rep < buyable.cost || buyable.stock === 0}
            icon="shopping-cart"
            content={"Buy (" + buyable.cost + " Rep)"}
            mt="0.5rem"
            onClick={() => act('purchase', {
              uid: buyable.uid,
            })}
          />
          {buyable.stock > -1 && (
            <Box
              as="span"
              color={buyable.stock === 0 ? "bad" : "good"}
              ml="0.5rem">
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
      this.setState(prevState => {
        return ({
          currentIndex: prevState.currentIndex + 1,
        });
      });
      const { currentDisplay } = state;
      currentDisplay.push(props.allMessages[state.currentIndex]);
    } else {
      clearTimeout(this.timer);
      setTimeout(props.onFinished, props.finishedTimeout);
    }
  }

  componentDidMount() {
    const {
      linesPerSecond = 2.5,
    } = this.props;
    this.timer = setInterval(() => this.tick(), 1000 / linesPerSecond);
  }

  componentWillUnmount() {
    clearTimeout(this.timer);
  }

  render() {
    return (
      <Box m={1}>
        {this.state.currentDisplay.map(value => (
          <Fragment key={value}>
            {value}
            <br />
          </Fragment>
        ))}
      </Box>
    );
  }
}

const PhotoZoom = (properties, context) => {
  const [viewingPhoto, setViewingPhoto] = useLocalState(context, "viewingPhoto", "");
  return (
    <Modal
      className="Contractor__photoZoom">
      <Box
        as="img"
        src={viewingPhoto}
      />
      <Button
        icon="times"
        content="Close"
        color="grey"
        mt="1rem"
        onClick={() => setViewingPhoto("")}
      />
    </Modal>
  );
};
