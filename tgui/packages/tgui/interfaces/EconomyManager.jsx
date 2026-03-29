import { Box, Button, Icon, LabeledList, NoticeBox, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { ComplexModal } from './common/ComplexModal';

export const EconomyManager = (props) => {
  return (
    <Window width={600} height={325}>
      <ComplexModal />
      <Window.Content scrollable className="Layout__content--flexColumn">
        <EconomyButtons />
      </Window.Content>
    </Window>
  );
};

const EconomyButtons = (properties) => {
  const { act, data } = useBackend();

  const { next_payroll_time } = data;

  return (
    <>
      <Section>
        <Box fontSize="1.4rem" bold>
          <Icon name="coins" verticalAlign="middle" size={3} mr="1rem" />
          Economy Manager
        </Box>
        <br />
        <LabeledList label="Pay Bonuses and Deductions">
          <LabeledList.Item label="Global">
            <Button
              icon="dollar-sign"
              width="auto"
              content="Global Payroll Modification"
              onClick={() =>
                act('payroll_modification', {
                  mod_type: 'global',
                })
              }
            />
          </LabeledList.Item>
          <LabeledList.Item label="Department Accounts">
            <Button
              icon="dollar-sign"
              width="auto"
              content="Department Account Payroll Modification"
              onClick={() =>
                act('payroll_modification', {
                  mod_type: 'department',
                })
              }
            />
          </LabeledList.Item>
          <LabeledList.Item label="Department Members">
            <Button
              icon="dollar-sign"
              width="auto"
              content="Department Members Payroll Modification"
              onClick={() =>
                act('payroll_modification', {
                  mod_type: 'department_members',
                })
              }
            />
          </LabeledList.Item>
          <LabeledList.Item label="Single Accounts">
            <Button
              icon="dollar-sign"
              width="auto"
              content="Crew Member Payroll Modification"
              onClick={() =>
                act('payroll_modification', {
                  mod_type: 'crew_member',
                })
              }
            />
          </LabeledList.Item>
        </LabeledList>
        <hr />
        <Box mb={0.5}>Next Payroll in: {next_payroll_time} Minutes</Box>
        <Button
          icon="angle-double-left"
          width="auto"
          color="bad"
          content="Delay Payroll"
          onClick={() => act('delay_payroll')}
        />
        <Button width="auto" content="Set Payroll Time" onClick={() => act('set_payroll')} />
        <Button
          icon="angle-double-right"
          width="auto"
          color="good"
          content="Accelerate Payroll"
          onClick={() => act('accelerate_payroll')}
        />
      </Section>
      <NoticeBox>
        <b>WARNING:</b> You take full responsibility for unbalancing the economy with these buttons!
      </NoticeBox>
    </>
  );
};
