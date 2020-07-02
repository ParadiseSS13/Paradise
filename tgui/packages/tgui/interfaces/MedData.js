import { Fragment } from 'inferno';
import { useBackend } from "../backend";
import { Window } from "../layouts";
import { AnimatedNumber, Box, Button, Collapsible, Flex, Icon, Input, LabeledList, Modal, NoticeBox, NumberInput, Section, Tabs, ByondUi } from "../components";
import { QuestionModal } from "../interfaces/common/QuestionModal";

const qModal = (act, id, question, choices, value) => {
  return () => act('questionmodal', {
    id: id,
    question: question,
    choices: choices,
    value: value,
  });
};

const severities = {
  "Minor": "good",
  "Medium": "average",
  "Dangerous!": "bad",
  "Harmful": "bad",
  "BIOHAZARD THREAT!": "bad",
};

export const MedData = (props, context) => {
  const { act, data, config } = useBackend(context);
  const {
    temp,
    scan,
    authenticated,
    screen,
    records,
    general,
    medical,
    virus,
    medbots,
    questionmodal,
    printing,
  } = data;
  if (!authenticated) {
    return (
      <Window resizable>
        <Window.Content>
          <Section title="Welcome" height="100%" stretchContents>
            <Flex height="100%" align="center" justify="center">
              <Flex.Item textAlign="center" mt="-2rem">
                <Box fontSize="1.5rem" bold>
                  <Icon
                    name="user-circle"
                    verticalAlign="middle"
                    size={3}
                    mr="1rem"
                  />
                  Guest
                </Box>
                <Box color="label" my="1rem">
                  ID:
                  <Button
                    icon="id-card"
                    content={scan ? scan : "----------"}
                    ml="0.5rem"
                    onClick={() => act('scan')}
                  />
                </Box>
                <Button
                  icon="sign-in-alt"
                  disabled={!scan}
                  content="Login"
                  onClick={() => act('login')}
                />
              </Flex.Item>
            </Flex>
          </Section>
        </Window.Content>
      </Window>
    );
  } else {
    let body;
    let questionModal = !!questionmodal && (
      <QuestionModal
        id={questionmodal.id}
        question={questionmodal.question}
        choices={questionmodal.choices}
        value={questionmodal.value}
      />
    );
    let tempNotice, tempModal;
    if (temp) {
      const tempProp = { [temp.style]: true };
      if (temp.style === "virus") {
        tempModal = (
          <Modal maxWidth="50%" ml="25%" p="0">
            <Section
              title={temp.text.name || 'Virus'}>
              <LabeledList>
                <LabeledList.Item label="Number of stages">
                  {temp.text.max_stages}
                </LabeledList.Item>
                <LabeledList.Item label="Spread">
                  {temp.text.spread_text} Transmission
                </LabeledList.Item>
                <LabeledList.Item label="Possible cure">
                  {temp.text.cure}
                </LabeledList.Item>
                <LabeledList.Item label="Notes">
                  {temp.text.desc}
                </LabeledList.Item>
                <LabeledList.Item label="Severity"
                  color={severities[temp.text.severity]}>
                  {temp.text.severity}
                </LabeledList.Item>
              </LabeledList>
              <Button
                icon="times-circle"
                content="Close"
                mt="1rem"
                onClick={() => act('cleartemp')}
              />
            </Section>
          </Modal>
        );
      } else {
        tempNotice = (
          <NoticeBox {...tempProp}>
            <Box display="inline-block" verticalAlign="middle">
              {temp.text}
            </Box>
            <Button
              icon="times-circle"
              float="right"
              onClick={() => act('cleartemp')}
            />
            <Box clear="both" />
          </NoticeBox>
        );
      }
    }
    if (screen === 2) { // List Records
      body = (
        <Fragment>
          <Input
            fluid
            placeholder="Search by Name, DNA, or ID"
            onChange={(e, value) => act('search', { t1: value })}
          />
          <Box mt="0.5rem">
            {records.map((record, i) => (
              <Button
                key={i}
                icon="user"
                mb="0.5rem"
                content={record.id + ": " + record.name}
                onClick={() => act('d_rec', { d_rec: record.ref })}
              />
            ))}
          </Box>
        </Fragment>
      );
    } else if (screen === 3) { // Record Maintenance
      body = (
        <Fragment>
          <Button
            icon="download"
            content="Backup to Disk"
            disabled
          /><br />
          <Button
            icon="upload"
            content="Upload from Disk"
            my="0.5rem"
            disabled
          /> <br />
          <Button.Confirm
            icon="trash"
            content="Delete All Medical Records"
            onClick={() => act('del_all')}
          />
        </Fragment>
      );
    } else if (screen === 4) { // View Records
      // General data
      const generalInfo = !general.empty ? (
        <Box width="50%" float="left">
          <LabeledList>
            {general.fields.map((field, i) => (
              <LabeledList.Item key={i} label={field.field}>
                <Box height="20px" display="inline-block">
                  {field.value}
                </Box>
                {!!field.edit && (
                  <Button
                    icon="pen"
                    ml="0.5rem"
                    onClick={qModal(act,
                      field.edit,
                      field.question,
                      field.question_choices,
                      field.value
                    )}
                  />
                )}
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Box>
      ) : (
        <Box color="bad">
          General records lost!
        </Box>
      );

      // Medical data
      const medicalInfo = !medical.empty ? (
        <Fragment>
          <LabeledList>
            {medical.fields.map((field, i) => (
              <LabeledList.Item
                key={i}
                label={field.field}>
                {field.value}
                <Button
                  icon="pen"
                  ml="0.5rem"
                  mb={field.line_break ? '1rem' : 'initial'}
                  onClick={qModal(act,
                    field.edit,
                    field.question,
                    field.question_choices,
                    field.value
                  )}
                />
              </LabeledList.Item>
            ))}
          </LabeledList>
          <Section title="Comments/Log" level={3}>
            {medical.comments.length === 0 ? (
              <Box color="label">
                No comments found.
              </Box>
            )
              : medical.comments.map((comment, i) => (
                <Box key={i}>
                  <Box color="label" display="inline">
                    {comment.header}
                  </Box><br />
                  {comment.text}
                  <Button
                    icon="comment-slash"
                    color="bad"
                    ml="0.5rem"
                    onClick={() => act('del_c', { del_c: i + 1 })}
                  />
                </Box>
              ))}

            <Button
              icon="comment-medical"
              content="Add Entry"
              color="good"
              mt="0.5rem"
              onClick={qModal(act, "add_c", "Please enter your comment:")}
            />
          </Section>
        </Fragment>
      ) : (
        <Box color="bad">
          Medical records lost!
          <Button
            icon="pen"
            content="New Record"
            ml="0.5rem"
            onClick={() => act('new')}
          />
        </Box>
      );

      const actions = (
        <Fragment>
          <Button.Confirm
            icon="trash"
            disabled={!!medical.empty}
            content="Delete Medical Record"
            color="bad"
            onClick={() => act('del_r')}
          />
          <Button
            icon={printing ? 'spinner' : 'print'}
            disabled={printing}
            iconSpin={!!printing}
            content="Print Entry"
            ml="0.5rem"
            onClick={() => act('print_p')}
          /><br />
          <Button
            icon="arrow-left"
            content="Back"
            mt="0.5rem"
            onClick={() => act('screen', { screen: 2 })}
          />
        </Fragment>
      );

      body = (
        <Fragment>
          <Section title="General Data" level={2} mb="-6px">
            {generalInfo}
          </Section>
          <Section title="Medical Data" level={2} mb="-12px">
            {medicalInfo}
          </Section>
          <Section title="Actions" level={2}>
            {actions}
          </Section>
        </Fragment>
      );
    } else if (screen === 5) { // Virus Database
      virus.sort((a, b) => a.name > b.name ? 1 : -1);
      body = virus.map((vir, i) => (
        <Fragment key={i}>
          <Button
            icon="flask"
            content={vir.name}
            mb="0.5rem"
            onClick={() => act('vir', { vir: vir.D })}
          />
          <br />
        </Fragment>
      ));
    } else if (screen === 6) { // Medbot Tracking
      body = medbots.length > 0
        ? medbots.map((medbot, i) => (
          <Collapsible
            key={i}
            open
            title={medbot.name}>
            <Box px="0.5rem">
              <LabeledList>
                <LabeledList.Item label="Location">
                  {medbot.area || 'Unknown'} ({medbot.x}, {medbot.y})
                </LabeledList.Item>
                <LabeledList.Item label="Status">
                  {medbot.on ? (
                    <Fragment>
                      <Box color="good">
                        Online
                      </Box>
                      <Box mt="0.5rem">
                        {medbot.use_beaker
                          ? ("Reservoir: "
                          + medbot.total_volume + "/" + medbot.maximum_volume)
                          : "Using internal synthesizer."}
                      </Box>
                    </Fragment>
                  ) : (
                    <Box color="average">
                      Offline
                    </Box>
                  )}
                </LabeledList.Item>
              </LabeledList>
            </Box>
          </Collapsible>
        )) : (
          <Box color="label">
            There are no Medbots.
          </Box>
        );
    }

    return (
      <Window resizable>
        {questionModal}
        {tempModal}
        <Window.Content className="Layout__content--flexColumn">
          <NoticeBox info>
            <Box display="inline-block" verticalAlign="middle">
              Logged in as: {scan}
            </Box>
            <Button
              icon="sign-out-alt"
              content="Logout and Eject ID"
              color="good"
              float="right"
              onClick={() => act('logout')}
            />
            <Box clear="both" />
          </NoticeBox>
          {tempNotice}
          <Tabs>
            <Tabs.Tab
              selected={screen === 2}
              onClick={() => act('screen', { screen: 2 })}>
              <Icon name="list" />
              List Records
            </Tabs.Tab>
            <Tabs.Tab
              selected={screen === 5}
              onClick={() => act('screen', { screen: 5 })}>
              <Icon name="database" />
              Virus Database
            </Tabs.Tab>
            <Tabs.Tab
              selected={screen === 6}
              onClick={() => act('screen', { screen: 6 })}>
              <Icon name="plus-square" />
              Medbot Tracking
            </Tabs.Tab>
            <Tabs.Tab
              selected={screen === 3}
              onClick={() => act('screen', { screen: 3 })}>
              <Icon name="wrench" />
              Record Maintenance
            </Tabs.Tab>
          </Tabs>
          <Section height="100%" flexGrow="1">
            <Box mt="-6px">
              {body}
            </Box>
          </Section>
        </Window.Content>
      </Window>
    );
  }
};
