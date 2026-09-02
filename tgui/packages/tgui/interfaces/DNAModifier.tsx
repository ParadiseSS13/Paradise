import {
  Box,
  Button,
  Dimmer,
  Flex,
  Icon,
  Knob,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { ComplexModal } from './common/ComplexModal';

interface DNAModifierData {
  irradiating: number;
  dnaBlockSize: number;
  locked: boolean;
  hasOccupant: boolean;
  hasDisk: boolean;
  isBeakerLoaded: boolean;
  isInjectorReady: boolean;
  selectedMenuKey: string;
  selectedUIBlock: number;
  selectedUISubBlock: number;
  selectedUITarget: number;
  selectedSEBlock: number;
  selectedSESubBlock: number;
  radiationIntensity: number;
  radiationDuration: number;
  beakerVolume: number;
  beakerLabel: string | null;
  occupant: {
    name: string;
    stat: number;
    health: number;
    minHealth: number;
    maxHealth: number;
    radiationLevel: number;
    isViableSubject: boolean;
    uniqueIdentity: string;
    uniqueEnzymes: string | null;
    structuralEnzymes: string;
  };
  disk: {
    data: boolean;
    label: string | null;
    owner: string | null;
    type: 'ui' | 'se';
    ue: boolean;
  };
  buffers: Array<{
    data: boolean;
    label: string;
    owner: string | null;
    type: 'ui' | 'se';
    ue: boolean;
  }>;
}

const stats: [string, string][] = [
  ['good', 'Alive'],
  ['average', 'Critical'],
  ['bad', 'DEAD'],
];

const operations: [string, string, string][] = [
  ['ui', 'Modify U.I.', 'dna'],
  ['se', 'Modify S.E.', 'dna'],
  ['buffer', 'Transfer Buffers', 'syringe'],
  ['rejuvenators', 'Rejuvenators', 'flask'],
];

const rejuvenatorsDoses: number[] = [5, 10, 20, 30, 50];

export const DNAModifier = () => {
  const { act, data } = useBackend<DNAModifierData>();
  const { irradiating, dnaBlockSize, occupant } = data;
  const isDNAInvalid = !occupant.isViableSubject || !occupant.uniqueIdentity || !occupant.structuralEnzymes;
  let radiatingModal;
  if (irradiating) {
    radiatingModal = <DNAModifierIrradiating duration={irradiating} />;
  }
  return (
    <Window width={660} height={800}>
      <ComplexModal />
      {radiatingModal}
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <DNAModifierOccupant isDNAInvalid={isDNAInvalid} />
          </Stack.Item>
          <Stack.Item grow>
            <DNAModifierMain dnaBlockSize={dnaBlockSize} isDNAInvalid={isDNAInvalid} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

interface DNAModifierOccupantProps {
  isDNAInvalid: boolean;
}

const DNAModifierOccupant = (props: DNAModifierOccupantProps) => {
  const { act, data } = useBackend<DNAModifierData>();
  const { locked, hasOccupant, occupant } = data;
  const { isDNAInvalid } = props;
  return (
    <Section
      title="Occupant"
      buttons={
        <>
          <Box color="label" inline mr="0.5rem">
            Door Lock:
          </Box>
          <Button
            disabled={!hasOccupant}
            selected={locked}
            icon={locked ? 'toggle-on' : 'toggle-off'}
            content={locked ? 'Engaged' : 'Disengaged'}
            onClick={() => act('toggleLock')}
          />
          <Button
            disabled={!hasOccupant || locked}
            icon="user-slash"
            content="Eject"
            onClick={() => act('ejectOccupant')}
          />
        </>
      }
    >
      {hasOccupant ? (
        <>
          <Box>
            <LabeledList>
              <LabeledList.Item label="Name">{occupant.name}</LabeledList.Item>
              <LabeledList.Item label="Health">
                <ProgressBar
                  minValue={occupant.minHealth}
                  maxValue={occupant.maxHealth}
                  value={occupant.health / occupant.maxHealth}
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0, 0.5],
                    bad: [-Infinity, 0],
                  }}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Status" color={stats[occupant.stat][0]}>
                {stats[occupant.stat][1]}
              </LabeledList.Item>
              <LabeledList.Divider />
            </LabeledList>
          </Box>
          {isDNAInvalid ? (
            <Box color="bad">
              <Icon name="exclamation-circle" />
              &nbsp; The occupant&apos;s DNA structure is ruined beyond recognition, please insert a subject with an
              intact DNA structure.
            </Box>
          ) : (
            <LabeledList>
              <LabeledList.Item label="Radiation">
                <ProgressBar minValue={0} maxValue={100} value={occupant.radiationLevel / 100} color="average" />
              </LabeledList.Item>
              <LabeledList.Item label="Unique Enzymes">
                {data.occupant.uniqueEnzymes ? (
                  data.occupant.uniqueEnzymes
                ) : (
                  <Box color="bad">
                    <Icon name="exclamation-circle" />
                    &nbsp; Unknown
                  </Box>
                )}
              </LabeledList.Item>
            </LabeledList>
          )}
        </>
      ) : (
        <Box color="label">Cell unoccupied.</Box>
      )}
    </Section>
  );
};

interface DNAModifierMainProps {
  dnaBlockSize: number;
  isDNAInvalid: boolean;
}

const DNAModifierMain = (props: DNAModifierMainProps) => {
  const { act, data } = useBackend<DNAModifierData>();
  const { selectedMenuKey, hasOccupant } = data;
  const { dnaBlockSize, isDNAInvalid } = props;

  if (!hasOccupant) {
    return (
      <Section fill>
        <Stack fill>
          <Stack.Item grow align="center" textAlign="center" color="label">
            <Icon name="user-slash" mb="0.5rem" size={5} />
            <br />
            No occupant in DNA modifier.
          </Stack.Item>
        </Stack>
      </Section>
    );
  } else if (isDNAInvalid) {
    return (
      <Section fill>
        <Stack fill>
          <Stack.Item grow align="center" textAlign="center" color="label">
            <Icon name="user-slash" mb="0.5rem" size={5} />
            <br />
            No operation possible on this subject.
          </Stack.Item>
        </Stack>
      </Section>
    );
  }
  let body;
  if (selectedMenuKey === 'ui') {
    body = (
      <>
        <DNAModifierMainUI dnaBlockSize={dnaBlockSize} />
        <DNAModifierMainRadiationEmitter />
      </>
    );
  } else if (selectedMenuKey === 'se') {
    body = (
      <>
        <DNAModifierMainSE dnaBlockSize={dnaBlockSize} />
        <DNAModifierMainRadiationEmitter />
      </>
    );
  } else if (selectedMenuKey === 'buffer') {
    body = <DNAModifierMainBuffers />;
  } else if (selectedMenuKey === 'rejuvenators') {
    body = <DNAModifierMainRejuvenators />;
  }
  return (
    <Section fill>
      <Tabs>
        {operations.map((op, i) => (
          <Tabs.Tab
            key={i}
            icon={op[2]}
            selected={selectedMenuKey === op[0]}
            onClick={() => act('selectMenuKey', { key: op[0] })}
          >
            {op[1]}
          </Tabs.Tab>
        ))}
      </Tabs>
      {body}
    </Section>
  );
};

interface DNAModifierMainUIProps {
  dnaBlockSize: number;
}

const DNAModifierMainUI = (props: DNAModifierMainUIProps) => {
  const { act, data } = useBackend<DNAModifierData>();
  const { selectedUIBlock, selectedUISubBlock, selectedUITarget, occupant } = data;
  const { dnaBlockSize } = props;
  return (
    <Section title="Modify Unique Identifier">
      <Stack vertical>
        <Stack.Item grow>
          <Section>
            <DNAModifierBlocks
              dnaString={occupant.uniqueIdentity}
              selectedBlock={selectedUIBlock}
              selectedSubblock={selectedUISubBlock}
              blockSize={dnaBlockSize}
              action="selectUIBlock"
            />
          </Section>
        </Stack.Item>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Target">
              <Knob
                minValue={1}
                maxValue={15}
                stepPixelSize={20}
                value={selectedUITarget}
                format={(value) => value.toString(16).toUpperCase()}
                ml="0"
                onChange={(e, val) => act('changeUITarget', { value: val })}
              />
            </LabeledList.Item>
          </LabeledList>
          <Button icon="radiation" content="Irradiate Block" mt="0.5rem" onClick={() => act('pulseUIRadiation')} />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

interface DNAModifierMainSEProps {
  dnaBlockSize: number;
}

const DNAModifierMainSE = (props: DNAModifierMainSEProps) => {
  const { act, data } = useBackend<DNAModifierData>();
  const { selectedSEBlock, selectedSESubBlock, occupant } = data;
  const { dnaBlockSize } = props;
  return (
    <Section title="Modify Structural Enzymes">
      <Stack vertical>
        <Stack.Item grow>
          <Section>
            <DNAModifierBlocks
              dnaString={occupant.structuralEnzymes}
              selectedBlock={selectedSEBlock}
              selectedSubblock={selectedSESubBlock}
              blockSize={dnaBlockSize}
              action="selectSEBlock"
            />
          </Section>
        </Stack.Item>
        <Stack.Item>
          <Button icon="radiation" content="Irradiate Block" onClick={() => act('pulseSERadiation')} />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const DNAModifierMainRadiationEmitter = () => {
  const { act, data } = useBackend<DNAModifierData>();
  const { radiationIntensity, radiationDuration } = data;
  return (
    <Section title="Radiation Emitter">
      <LabeledList>
        <LabeledList.Item label="Intensity">
          <Knob
            minValue={1}
            maxValue={10}
            stepPixelSize={20}
            value={radiationIntensity}
            popupPosition="right"
            ml="0"
            onChange={(e, val) => act('radiationIntensity', { value: val })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Duration">
          <Knob
            minValue={1}
            maxValue={20}
            stepPixelSize={10}
            unit="s"
            value={radiationDuration}
            popupPosition="right"
            ml="0"
            onChange={(e, val) => act('radiationDuration', { value: val })}
          />
        </LabeledList.Item>
      </LabeledList>
      <Button
        icon="radiation"
        content="Pulse Radiation"
        tooltip="Mutates a random block of either the occupant's UI or SE."
        tooltipPosition="top-start"
        mt="0.5rem"
        onClick={() => act('pulseRadiation')}
      />
    </Section>
  );
};

const DNAModifierMainBuffers = () => {
  const { data } = useBackend<DNAModifierData>();
  const { buffers } = data;
  let bufferElements = buffers.map((buffer, i) => (
    <DNAModifierMainBuffersElement key={i} id={i + 1} name={'Buffer ' + (i + 1)} buffer={buffer} />
  ));
  return (
    <Stack fill vertical>
      <Stack.Item height="75%" mt={1}>
        <Section fill scrollable title="Buffers">
          {bufferElements}
        </Section>
      </Stack.Item>
      <Stack.Item height="25%">
        <DNAModifierMainBuffersDisk />
      </Stack.Item>
    </Stack>
  );
};

interface BufferData {
  data: boolean;
  label: string;
  owner: string | null;
  type: 'ui' | 'se';
  ue: boolean;
}

interface DNAModifierMainBuffersElementProps {
  id: number;
  name: string;
  buffer: BufferData;
}

const DNAModifierMainBuffersElement = (props: DNAModifierMainBuffersElementProps) => {
  const { act, data } = useBackend<DNAModifierData>();
  const { id, name, buffer } = props;
  const isInjectorReady = data.isInjectorReady;
  const realName = name + (buffer.data ? ' - ' + buffer.label : '');
  return (
    <Box backgroundColor="rgba(0, 0, 0, 0.33)" mb="0.5rem">
      <Section
        title={realName}
        mx="0"
        lineHeight="18px"
        buttons={
          <>
            <Button.Confirm
              disabled={!buffer.data}
              icon="trash"
              content="Clear"
              onClick={() =>
                act('bufferOption', {
                  option: 'clear',
                  id: id,
                })
              }
            />
            <Button
              disabled={!buffer.data}
              icon="pen"
              content="Rename"
              onClick={() =>
                act('bufferOption', {
                  option: 'changeLabel',
                  id: id,
                })
              }
            />
            <Button
              disabled={!buffer.data || !data.hasDisk}
              icon="save"
              content="Export"
              tooltip="Exports this buffer to the currently loaded data disk."
              tooltipPosition="bottom-start"
              onClick={() =>
                act('bufferOption', {
                  option: 'saveDisk',
                  id: id,
                })
              }
            />
          </>
        }
      >
        <LabeledList>
          <LabeledList.Item label="Write">
            <Button
              icon="arrow-circle-down"
              content="Subject U.I"
              mb="0"
              onClick={() =>
                act('bufferOption', {
                  option: 'saveUI',
                  id: id,
                })
              }
            />
            <Button
              icon="arrow-circle-down"
              content="Subject U.I and U.E."
              mb="0"
              onClick={() =>
                act('bufferOption', {
                  option: 'saveUIAndUE',
                  id: id,
                })
              }
            />
            <Button
              icon="arrow-circle-down"
              content="Subject S.E."
              mb="0"
              onClick={() =>
                act('bufferOption', {
                  option: 'saveSE',
                  id: id,
                })
              }
            />
            <Button
              disabled={!data.hasDisk || !data.disk.data}
              icon="arrow-circle-down"
              content="From Disk"
              mb="0"
              onClick={() =>
                act('bufferOption', {
                  option: 'loadDisk',
                  id: id,
                })
              }
            />
          </LabeledList.Item>
          {!!buffer.data && (
            <>
              <LabeledList.Item label="Subject">{buffer.owner || <Box color="average">Unknown</Box>}</LabeledList.Item>
              <LabeledList.Item label="Data Type">
                {buffer.type === 'ui' ? 'Unique Identifiers' : 'Structural Enzymes'}
                {!!buffer.ue && ' and Unique Enzymes'}
              </LabeledList.Item>
              <LabeledList.Item label="Transfer to">
                <Button
                  disabled={!isInjectorReady}
                  icon={isInjectorReady ? 'syringe' : 'spinner'}
                  iconSpin={!isInjectorReady}
                  content="Injector"
                  mb="0"
                  onClick={() =>
                    act('bufferOption', {
                      option: 'createInjector',
                      id: id,
                    })
                  }
                />
                <Button
                  disabled={!isInjectorReady}
                  icon={isInjectorReady ? 'syringe' : 'spinner'}
                  iconSpin={!isInjectorReady}
                  content="Block Injector"
                  mb="0"
                  onClick={() =>
                    act('bufferOption', {
                      option: 'createInjector',
                      id: id,
                      block: 1,
                    })
                  }
                />
                <Button
                  icon="user"
                  content="Subject"
                  mb="0"
                  onClick={() =>
                    act('bufferOption', {
                      option: 'transfer',
                      id: id,
                    })
                  }
                />
              </LabeledList.Item>
            </>
          )}
        </LabeledList>
        {!buffer.data && (
          <Box color="label" mt="0.5rem">
            This buffer is empty.
          </Box>
        )}
      </Section>
    </Box>
  );
};

const DNAModifierMainBuffersDisk = () => {
  const { act, data } = useBackend<DNAModifierData>();
  const { hasDisk, disk } = data;
  return (
    <Section
      title="Data Disk"
      buttons={
        <>
          <Button.Confirm
            disabled={!hasDisk || !disk.data}
            icon="trash"
            content="Wipe"
            onClick={() => act('wipeDisk')}
          />
          <Button disabled={!hasDisk} icon="eject" content="Eject" onClick={() => act('ejectDisk')} />
        </>
      }
    >
      {hasDisk ? (
        disk.data ? (
          <LabeledList>
            <LabeledList.Item label="Label">{disk.label ? disk.label : 'No label'}</LabeledList.Item>
            <LabeledList.Item label="Subject">
              {disk.owner ? disk.owner : <Box color="average">Unknown</Box>}
            </LabeledList.Item>
            <LabeledList.Item label="Data Type">
              {disk.type === 'ui' ? 'Unique Identifiers' : 'Structural Enzymes'}
              {!!disk.ue && ' and Unique Enzymes'}
            </LabeledList.Item>
          </LabeledList>
        ) : (
          <Box color="label">Disk is blank.</Box>
        )
      ) : (
        <Box color="label" textAlign="center" my="1rem">
          <Icon name="save-o" size={4} />
          <br />
          No disk inserted.
        </Box>
      )}
    </Section>
  );
};

const DNAModifierMainRejuvenators = () => {
  const { act, data } = useBackend<DNAModifierData>();
  const { isBeakerLoaded, beakerVolume, beakerLabel } = data;
  return (
    <Section
      fill
      title="Rejuvenators and Beaker"
      buttons={<Button disabled={!isBeakerLoaded} icon="eject" content="Eject" onClick={() => act('ejectBeaker')} />}
    >
      {isBeakerLoaded ? (
        <LabeledList>
          <LabeledList.Item label="Inject">
            {rejuvenatorsDoses.map((a, i) => (
              <Button
                key={i}
                disabled={a > beakerVolume}
                icon="syringe"
                content={a}
                onClick={() =>
                  act('injectRejuvenators', {
                    amount: a,
                  })
                }
              />
            ))}
            <Button
              disabled={beakerVolume <= 0}
              icon="syringe"
              content="All"
              onClick={() =>
                act('injectRejuvenators', {
                  amount: beakerVolume,
                })
              }
            />
          </LabeledList.Item>
          <LabeledList.Item label="Beaker">
            <Box mb="0.5rem">{beakerLabel ? beakerLabel : 'No label'}</Box>
            {beakerVolume ? (
              <Box color="good">
                {beakerVolume} unit{beakerVolume === 1 ? '' : 's'} remaining
              </Box>
            ) : (
              <Box color="bad">Empty</Box>
            )}
          </LabeledList.Item>
        </LabeledList>
      ) : (
        <Stack fill vertical align="center" justify="center">
          <Stack.Item>
            <Icon.Stack>
              <Icon name="flask" size={5} color="silver" />
              <Icon name="slash" size={5} color="red" />
            </Icon.Stack>
          </Stack.Item>
          <Stack.Item bold color="label" mb="2rem">
            <h3>No Beaker Loaded</h3>
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
};

interface DNAModifierIrradiatingProps {
  duration: number;
}

const DNAModifierIrradiating = (props: DNAModifierIrradiatingProps) => {
  const { duration } = props;
  return (
    <Dimmer textAlign="center">
      <Icon name="spinner" size={5} spin />
      <br />
      <Box color="average">
        <h1>
          <Icon name="radiation" />
          &nbsp;Irradiating occupant&nbsp;
          <Icon name="radiation" />
        </h1>
      </Box>
      <Box color="label">
        <h3>
          For {duration} second{duration === 1 ? '' : 's'}
        </h3>
      </Box>
    </Dimmer>
  );
};

interface DNAModifierBlocksProps {
  dnaString: string;
  selectedBlock: number;
  selectedSubblock: number;
  blockSize: number;
  action: string;
}

const DNAModifierBlocks = (props: DNAModifierBlocksProps) => {
  const { act } = useBackend<DNAModifierData>();
  const { dnaString, selectedBlock, selectedSubblock, blockSize, action } = props;

  const characters = dnaString.split('');
  // Explicitly type the arrays to fix TypeScript errors
  const dnaBlocks: React.ReactNode[] = [];

  for (let block = 0; block < characters.length; block += blockSize) {
    const realBlock = block / blockSize + 1;
    const subBlocks: React.ReactNode[] = [];

    for (let subblock = 0; subblock < blockSize; subblock++) {
      const realSubblock = subblock + 1;
      subBlocks.push(
        <Button
          key={subblock}
          selected={selectedBlock === realBlock && selectedSubblock === realSubblock}
          content={characters[block + subblock]}
          mb="0"
          onClick={() =>
            act(action, {
              block: realBlock,
              subblock: realSubblock,
            })
          }
        />
      );
    }

    dnaBlocks.push(
      <Stack.Item key={block} mb="1rem" mr="1rem" width={7.8} textAlign="right">
        <Box inline mr="0.5rem" fontFamily="monospace">
          {realBlock}
        </Box>
        {subBlocks}
      </Stack.Item>
    );
  }

  return <Flex wrap="wrap">{dnaBlocks}</Flex>;
};
