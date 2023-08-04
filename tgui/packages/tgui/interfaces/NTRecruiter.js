import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section, Flex } from '../components';
import { LabeledListItem } from '../components/LabeledList';
import { Window } from '../layouts';

export const NTRecruiter = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    gamestatus,
    cand_name,
    cand_gender,
	  cand_age,
	  cand_species,
	  cand_planet,
	  cand_job,
	  cand_records,
	  cand_curriculum,
    reason,
  } = data;
  if (gamestatus === 0) {
  return (
    <Window resizable>
      <Window.Content>
        <Section title="Nanotrasen Recruiter Simulator" textAlign="center" color="label">
          Work as the Nanotrasen recruiter and avoid hiring incompetent employees!
        </Section>
        <Section>
          <Button
            lineHeight={2}
            fluid
            icon="play"
            color="green"
            content="Begin Game"
            onClick={() => act('start_game')}
          />
          <Button
            lineHeight={2}
            fluid
            icon="info"
            color="blue"
            content="Tips"
            onClick={() => act('instructions')}
          />
        </Section>
      </Window.Content>
    </Window>
    )}
  if (gamestatus === 1) {
  return (
    <Window resizable>
      <Window.Content>
        <Section
          color="label"
          title="Tips"
          buttons={
            <Button
              icon="arrow-left"
              content="Main Menu"
              onClick={() => act('back_to_menu')}
            />
          }
        >
        <Box>
          1# To win this game you must hire/dismiss FIVE candidates,
          one choice made wrong leads to game over.
          <br/>
          <br/>
          2# Make the right choice by truly putting yourself into
          the skin of a recruiter working for Nanotrasen!
          <br/>
          <br/>
          3# Unique characters may appear, pay attention to them!
          <br/>
          <br/>
          4# Make sure to pay attention to details like ages,
          planet names, jobs offered by NT and even the species of the candidate!
          <br/>
          <br/>
          5# Not every employment record is good, remember to make
          your choice based on the company morals!
        </Box>
        </Section>
      </Window.Content>
    </Window>
    )}
    if (gamestatus === 2) {
    return (
    <Window resizable>
      <Window.Content>
        <Section
          color="label"
          fontSize="14px"
          title="Employment Applications">
          <Box fontSize="24px" textAlign="center" color="silver" bold>
            Candidate Number #{cand_curriculum}
          </Box>
          <br/>
            <LabeledList>
              <LabeledListItem label="Name" color="silver">
                <b>{cand_name}</b>
              </LabeledListItem>
              <LabeledListItem label="Gender" color="silver">
                <b>{cand_gender}</b>
              </LabeledListItem>
              <LabeledListItem label="Age" color="silver">
                <b>{cand_age}</b>
              </LabeledListItem>
              <LabeledListItem label="Species" color="silver">
                <b>{cand_species}</b>
              </LabeledListItem>
              <LabeledListItem label="Planet of Origin" color="silver">
                <b>{cand_planet}</b>
              </LabeledListItem>
              <LabeledListItem label="Requested Job" color="silver">
                <b>{cand_job}</b>
              </LabeledListItem>
              <LabeledListItem label="Employment Records" color="silver">
                <b>{cand_records}</b>
              </LabeledListItem>
            </LabeledList>
        </Section>
        <Section
          title="Stamp the application!"
          color="silver"
          textAlign="center">
        <>
          <Box float="center">
            <Button
              color = "green"
              content="Hire"
              width="100%"
              icon="arrow-circle-up"
              lineHeight={3}
              onClick={() => act('hire')}
            />
          </Box>
          <Box float="center">
            <Button
            color = "red"
            content="Dismiss"
            width="100%"
            icon="ban"
            lineHeight={3}
            onClick={() => act('dismiss')}
            />
          </Box>
        </>
        </Section>
      </Window.Content>
    </Window>
    )}
    if (gamestatus === 3) {
    return (
    <Window resizable>
      <Window.Content>
        <Section>
          <Flex.Item color="red" fontSize="32px" textAlign="center">
            {"Game Over"}
          </Flex.Item>
          <Flex.Item fontSize="15px" color="label" textAlign="center">
            {reason}
          <Flex.Item color="blue" fontSize="20px" textAlign="center">
            FINAL SCORE: {cand_curriculum-1}/5
          </Flex.Item>
          </Flex.Item>
            <Button
              lineHeight={2}
              fluid
              icon="arrow-left"
              content="Main Menu"
              onClick={() => act('back_to_menu')}
            />
        </Section>
      </Window.Content>
    </Window>
    )}}
