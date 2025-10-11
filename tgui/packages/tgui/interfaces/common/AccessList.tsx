import { sortBy } from 'common/collections';
import { useState } from 'react';
import { Box, Button, Divider, LabeledList, Section, Stack, Tabs } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

export type Access = {
  desc: string;
  ref: number;
};

export type AccessRegion = {
  name: string;
  regid: number;
  accesses: Access[];
};

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

type AccessListProps = {
  sectionButtons?: React.JSX.Element;
  usedByRcd?: BooleanLike;
  rcdButtons?: React.JSX.Element;
  accesses: AccessRegion[];
  selectedList?: number[];
  grantableList?: number[];
  accessMod: (ref: number) => void;
  denyAll: () => void;
  grantAll: () => void;
  grantDep: (ref: number) => void;
  denyDep: (ref: number) => void;
};

export const AccessList = (props: AccessListProps) => {
  const {
    sectionButtons = null,
    usedByRcd = false,
    rcdButtons = null,
    accesses = [],
    selectedList = [],
    grantableList = [],
    accessMod,
    grantAll,
    denyAll,
    grantDep,
    denyDep,
  } = props;
  const [selectedAccessName, setSelectedAccessName] = useState(accesses[0]?.name);
  const selectedAccess = accesses.find((access) => access.name === selectedAccessName);
  let selectedAccessEntries: Access[] = [];
  if (selectedAccess) {
    selectedAccessEntries = sortBy(selectedAccess.accesses, (entry: Access) => entry.desc);
  }

  const checkAccessIcon = (accesses: Access[]) => {
    let oneAccess = false;
    let oneInaccess = false;
    for (let element of accesses) {
      if (selectedList.includes(element.ref)) {
        oneAccess = true;
      } else {
        oneInaccess = true;
      }
    }
    if (!oneAccess && oneInaccess) {
      return 0;
    } else if (oneAccess && oneInaccess) {
      return 1;
    } else {
      return 2;
    }
  };

  return (
    <Section
      fill
      scrollable
      title="Access"
      buttons={
        <>
          <Button icon="check-double" content="Select All" color="good" onClick={() => grantAll()} />
          <Button icon="undo" content="Deselect All" color="bad" onClick={() => denyAll()} />
          {sectionButtons}
        </>
      }
    >
      <Stack>
        <Stack.Item grow basis="25%">
          <Tabs vertical>
            {accesses.map((access) => {
              const entries = access.accesses || [];
              const icon = diffMap[checkAccessIcon(entries)].icon;
              const color = diffMap[checkAccessIcon(entries)].color;
              return (
                <Tabs.Tab
                  key={access.name}
                  color={color}
                  icon={icon}
                  selected={access.name === selectedAccessName}
                  onClick={() => setSelectedAccessName(access.name)}
                >
                  {access.name}
                </Tabs.Tab>
              );
            })}
          </Tabs>
        </Stack.Item>
        <Stack.Item>
          <Divider vertical />
        </Stack.Item>
        <Stack.Item grow basis="80%">
          <Stack mb={1}>
            <Stack.Item grow>
              <Button
                fluid
                icon="check"
                content="Select All In Region"
                color="good"
                onClick={() => selectedAccess && grantDep(selectedAccess.regid)}
              />
            </Stack.Item>
            <Stack.Item grow>
              <Button
                fluid
                icon="times"
                content="Deselect All In Region"
                color="bad"
                onClick={() => selectedAccess && denyDep(selectedAccess.regid)}
              />
            </Stack.Item>
          </Stack>
          {!!usedByRcd && (
            <Box my={1.5}>
              <LabeledList>
                <LabeledList.Item label="Require">{rcdButtons}</LabeledList.Item>
              </LabeledList>
            </Box>
          )}
          {selectedAccessEntries.map((entry) => (
            <Button.Checkbox
              fluid
              key={entry.desc}
              content={entry.desc}
              disabled={
                grantableList.length > 0 && !grantableList.includes(entry.ref) && !selectedList.includes(entry.ref)
              }
              checked={selectedList.includes(entry.ref)}
              onClick={() => accessMod(entry.ref)}
            />
          ))}
        </Stack.Item>
      </Stack>
    </Section>
  );
};
