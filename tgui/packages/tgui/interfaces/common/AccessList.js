import { sortBy } from 'common/collections';
import { Fragment } from 'inferno';
import { useLocalState } from '../../backend';
import { Box, Button, Flex, LabeledList, Section, Tabs } from '../../components';

const diffMap = {
  0: {
    icon: 'times-circle',
    color: 'bad',
  },
  1: {
    icon: 'stop-circle',
    color: null,
  },
  2: {
    icon: 'check-circle',
    color: 'good',
  },
};

export const AccessList = (props, context) => {
  const {
    sectionButtons = null,
    sectionFlexGrow = null,
    usedByRcd,
    rcdButtons,
    accesses = [],
    selectedList = [],
    accessMod,
    grantAll,
    denyAll,
    grantDep,
    denyDep,
  } = props;
  const [
    selectedAccessName,
    setSelectedAccessName,
  ] = useLocalState(context, 'accessName', accesses[0]?.name);
  const selectedAccess = accesses
    .find(access => access.name === selectedAccessName);
  const selectedAccessEntries = sortBy(
    entry => entry.desc,
  )(selectedAccess?.accesses || []);

  const checkAccessIcon = accesses => {
    let oneAccess = false;
    let oneInaccess = false;
    for (let element of accesses) {
      if (selectedList.includes(element.ref)) {
        oneAccess = true;
      }
      else {
        oneInaccess = true;
      }
    }
    if (!oneAccess && oneInaccess) {
      return 0;
    }
    else if (oneAccess && oneInaccess) {
      return 1;
    }
    else {
      return 2;
    }
  };

  return (
    <Section
      title="Access"
      flexGrow={sectionFlexGrow}
      buttons={(
        <Fragment>
          <Button
            icon="check-double"
            content="Select All"
            color="good"
            onClick={() => grantAll()} />
          <Button
            icon="undo"
            content="Deselect All"
            color="bad"
            onClick={() => denyAll()} />
          {sectionButtons}
        </Fragment>
      )}>
      <Flex>
        <Flex.Item>
          <Tabs vertical>
            {accesses.map(access => {
              const entries = access.accesses || [];
              const icon = diffMap[checkAccessIcon(entries)].icon;
              const color = diffMap[checkAccessIcon(entries)].color;
              return (
                <Tabs.Tab
                  key={access.name}
                  altSelection
                  color={color}
                  icon={icon}
                  selected={access.name === selectedAccessName}
                  onClick={() => setSelectedAccessName(access.name)}>
                  {access.name}
                </Tabs.Tab>
              );
            })}
          </Tabs>
        </Flex.Item>
        <Flex.Item grow={1}>
          <Flex>
            <Flex.Item width="50%" mr={0.45}>
              <Button
                fluid
                icon="check"
                content="Select All In Region"
                color="good"
                onClick={() => grantDep(selectedAccess.regid)} />
            </Flex.Item>
            <Flex.Item width="50%" ml={0}>
              <Button
                fluid
                icon="times"
                content="Deselect All In Region"
                color="bad"
                onClick={() => denyDep(selectedAccess.regid)} />
            </Flex.Item>
          </Flex>
          {!!usedByRcd && (
            <Box my={1.5}>
              <LabeledList>
                <LabeledList.Item label="Require">
                  {rcdButtons}
                </LabeledList.Item>
              </LabeledList>
            </Box>
          )}
          {selectedAccessEntries.map(entry => (
            <Button.Checkbox
              fluid
              key={entry.desc}
              content={entry.desc}
              checked={selectedList.includes(entry.ref)}
              onClick={() => accessMod(entry.ref)} />
          ))}
        </Flex.Item>
      </Flex>
    </Section>
  );
};
