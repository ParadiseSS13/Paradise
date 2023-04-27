import { useBackend } from "../backend";
import { Button, Section, LabeledList, Box, ProgressBar, Flex, Tabs, Icon } from "../components";
import { Window } from "../layouts";
import { ComplexModal, modalOpen } from "./common/ComplexModal";
import { AccessList } from './common/AccessList';
import { Fragment } from "inferno";

export const RCD = (props, context) => {
  return (
    <Window resizable>
      <ComplexModal />
      <Window.Content display="flex" className="Layout__content--flexColumn">
        <MatterReadout />
        <ConstructionType />
        <AirlockSettings />
        <TypesAndAccess />
      </Window.Content>
    </Window>
  );
};

const MatterReadout = (props, context) => {
  const { data } = useBackend(context);
  const {
    matter,
    max_matter,
  } = data;
  const good_matter = max_matter * 0.70;
  const average_matter = max_matter * 0.25;
  return (
    <Section
      title="Matter Storage"
      flexBasis="content">
      <ProgressBar
        ranges={{
          good: [good_matter, Infinity],
          average: [average_matter, good_matter],
          bad: [-Infinity, average_matter],
        }}
        value={matter}
        maxValue={max_matter}>
        <Box textAlign="center">
          {matter + " / " + max_matter + " units"}
        </Box>
      </ProgressBar>
    </Section>
  );
};

const ConstructionType = () => {
  return (
    <Section
      title="Construction Type"
      flexBasis="content">
      <Flex>
        <Flex.Item>
          <ConstructionTypeCheckbox mode_type="Floors and Walls" />
          <ConstructionTypeCheckbox mode_type="Airlocks" />
          <ConstructionTypeCheckbox mode_type="Windows" />
          <ConstructionTypeCheckbox mode_type="Deconstruction" />
          <ConstructionTypeCheckbox mode_type="Firelocks" />
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const ConstructionTypeCheckbox = (props, context) => {
  const { act, data } = useBackend(context);
  const { mode_type } = props;
  const { mode } = data;
  return (
    <Button.Checkbox
      content={mode_type}
      checked={mode === mode_type ? 1 : 0}
      onClick={() => act('mode', {
        mode: mode_type,
      })} />
  );
};

const AirlockSettings = (props, context) => {
  const { data } = useBackend(context);
  const { door_name } = data;
  return (
    <Section
      title="Airlock Settings"
      flexBasis="content"
      height={5.5}>
      <LabeledList>
        <LabeledList.Item color="silver" label="Name">
          {door_name}
          <Button
            ml={2.5}
            icon="pen-alt"
            content="Edit"
            onClick={() => modalOpen(context, 'renameAirlock')}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const TypesAndAccess = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    tab,
    locked,
    one_access,
    selected_accesses,
    regions,
  } = data;
  return (
    <Fragment>
      <Tabs>
        <Tabs.Tab
          content="Airlock Types"
          icon="cog"
          selected={tab === 1}
          onClick={() => act('set_tab', {
            tab: 1,
          })}
        />
        <Tabs.Tab
          selected={tab === 2}
          content="Airlock Access"
          icon="list"
          onClick={() => act('set_tab', {
            tab: 2,
          })}
        />
      </Tabs>
      {tab === 1 ? (
        <Section
          title="Types"
          flexGrow="1">
          <Flex>
            <Flex.Item width="50%" mr={1}>
              <AirlockTypeList check_number={0} />
            </Flex.Item>
            <Flex.Item width="50%">
              <AirlockTypeList check_number={1} />
            </Flex.Item>
          </Flex>
        </Section>
      ) : (tab === 2 && locked) ? (
        <Section
          title="Access"
          flexGrow="1"
          buttons={
            <Button
              icon="lock-open"
              content="Unlock"
              onClick={() => act('set_lock', {
                new_lock: "unlock",
              })}
            />
          }>
          <Flex height="100%">
            <Flex.Item
              grow="1"
              textAlign="center"
              align="center"
              color="label">
              <Icon
                name="lock"
                size="5"
                mb={3}
              /><br />
              Airlock access selection is currently locked.
            </Flex.Item>
          </Flex>
        </Section>
      ) : (
        <AccessList
          sectionFlexGrow="1"
          sectionButtons={
            <Button
              icon="lock"
              content="Lock"
              onClick={() => act('set_lock', {
                new_lock: "lock",
              })}
            />
          }
          usedByRcd={1}
          rcdButtons={
            <Fragment>
              <Button.Checkbox
                checked={one_access}
                content="One"
                onClick={() => act('set_one_access', {
                  access: "one",
                })}
              />
              <Button.Checkbox
                checked={!one_access}
                width={4}
                content="All"
                onClick={() => act('set_one_access', {
                  access: "all",
                })}
              />
            </Fragment>
          }
          accesses={regions}
          selectedList={selected_accesses}
          accessMod={ref => act('set', {
            access: ref,
          })}
          grantAll={() => act('grant_all')}
          denyAll={() => act('clear_all')}
          grantDep={ref => act('grant_region', {
            region: ref,
          })}
          denyDep={ref => act('deny_region', {
            region: ref,
          })}
        />
      )}
    </Fragment>
  );
};

const AirlockTypeList = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    door_types_ui_list,
    door_type,
  } = data;
  const { check_number } = props;
  // Filter either odd or even airlocks in the list, based on what `check_number` is.
  const doors_filtered = [];
  for (let i = 0; i < door_types_ui_list.length; i++) {
    if (i % 2 === check_number) {
      doors_filtered.push(door_types_ui_list[i]);
    }
  }
  return (
    <Box>
      {doors_filtered.map((entry, i) => (
        <Flex key={i} mb={1}>
          <Flex.Item>
            <img
              src={`data:image/jpeg;base64,${entry.image}`}
              style={{
                'vertical-align': 'middle',
                width: '32px',
                margin: '0px',
                'margin-left': '0px',
              }}
            />
          </Flex.Item>
          <Flex.Item>
            <Button.Checkbox
              ml={1.5}
              mt={1}
              width={14}
              checked={door_type === entry.type}
              content={entry.name}
              onClick={() => act('door_type', {
                door_type: entry.type,
              })}
            />
          </Flex.Item>
        </Flex>
      ))}
    </Box>
  );
};
