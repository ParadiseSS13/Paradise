import { classes } from 'common/react';
import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, Flex, Icon, LabeledList, Section, Tabs } from '../components';
import { Window } from '../layouts';

const contractStatuses = {
  1: ["ACTIVE", "good"],
  2: ["COMPLETED", "good"],
  3: ["FAILED", "bad"],
};

export const Contractor = (properties, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window theme="syndicate">
      <Window.Content className={classes([
        "Contractor",
        "Layout__content--flexColumn",
      ])}>
        <ContractorSummary />
        <ContractorNavigation />
        <ContractorContracts />
      </Window.Content>
    </Window>
  );
};

const ContractorSummary = (properties, context) => {
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
      }>
      <Flex>
        <Box flexBasis="50%">
          <LabeledList>
            <LabeledList.Item label="TC Available" verticalAlign="middle">
              <Flex align="center">
                <Box flexGrow="1">
                  {tc_available} TC
                </Box>
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

const ContractorNavigation = (properties, context) => {
  const { act, data } = useBackend(context);
  return (
    <Tabs>
      <Tabs.Tab selected>
        <Icon name="suitcase" />
        Contracts
      </Tabs.Tab>
      <Tabs.Tab>
        <Icon name="shopping-cart" />
        Hub
      </Tabs.Tab>
    </Tabs>
  );
};

const ContractorContracts = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    contracts,
    contract_active,
    can_extract,
  } = data;
  return (
    <Section
      title="Available Contracts"
      flexGrow="1"
      stretchContents
      buttons={
        <Button
          disabled={!can_extract}
          icon="parachute-box"
          content="Call Extraction"
          onClick={() => act("extract")}
        />
      }>
      {contracts.map(contract => (
        <Section
          key={contract.uid}
          title={(
            <Fragment>
              {contract.target_name}
              <Button
                icon="camera"
                mb="0"
                ml="0.5rem"
              />
              {/* TODO */}
            </Fragment>
          )}
          className="Contractor__Contract"
          buttons={(
            <Box width="100%">
              {!!contractStatuses[contract.status] && (
                <Box
                  color={contractStatuses[contract.status][1]}
                  display="inline-block"
                  mt={contract.status !== 1 && "0.25rem"}
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
            <Box flexGrow="2" mr="0.5rem">
              {contract.fluff_message}
              {!!contract.completed_time && (
                <Box color="good">
                  <br />
                  Contract completed at {contract.completed_time}
                </Box>
              )}
              {!!contract.fail_reason && (
                <Box color="bad">
                  <br />
                  Contract failed: {contract.fail_reason}
                </Box>
              )}
            </Box>
            <Box flexGrow="1" flexBasis="100%">
              <Box mb="0.5rem" color="label">
                Extraction Zone:
              </Box>
              {contract.difficulties?.map((difficulty, key) => (
                <Button.Confirm
                  disabled={!!contract_active}
                  content={difficulty.name + " (" + difficulty.reward + " TC)"}
                  onClick={() => act("activate", {
                    uid: contract.uid,
                    difficulty: key + 1,
                  })}
                />
              ))}
              {!!contract.objective && (
                <Box color="white" bold>
                  {contract.objective.extraction_zone}<br />
                  ({(contract.objective.reward_tc || 0) + " TC"},&nbsp;
                  {(contract.objective.reward_credits || 0) + " Credits"})
                </Box>
              )}
            </Box>
          </Flex>
        </Section>
      ))}
    </Section>
  );
};
