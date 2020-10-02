import { Fragment } from 'inferno';
import { useBackend } from "../backend";
import { Box, Button, Dimmer, Flex, Icon, Knob, LabeledList, ProgressBar, Section, Tabs } from "../components";
import { Window } from "../layouts";
import { ComplexModal } from './common/ComplexModal';

const stats = [
  ['good', 'Alive'],
  ['average', 'Critical'],
  ['bad', 'DEAD'],
];

const operations = [
  ['ui', 'Modify U.I.', 'dna'],
  ['se', 'Modify S.E.', 'dna'],
  ['buffer', 'Transfer Buffers', 'syringe'],
  ['rejuvenators', 'Rejuvenators', 'flask'],
];

const rejuvenatorsDoses = [5, 10, 20, 30, 50];

export const DNAModifier = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    irradiating,
    dnaBlockSize,
    occupant,
  } = data;
  context.dnaBlockSize = dnaBlockSize;
  context.isDNAInvalid = !occupant.isViableSubject
                         || !occupant.uniqueIdentity
                         || !occupant.structuralEnzymes;
  let radiatingModal;
  if (irradiating) {
    radiatingModal = <DNAModifierIrradiating duration={irradiating} />;
  }
  return (
    <Window resizable>
      <ComplexModal />
      {radiatingModal}
      <Window.Content className="Layout__content--flexColumn">
        <DNAModifierOccupant />
        <DNAModifierMain />
      </Window.Content>
    </Window>
  );
};

const DNAModifierOccupant = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    locked,
    hasOccupant,
    occupant,
  } = data;
  return (
    <Section
      title="Occupant"
      buttons={
        <Fragment>
          <Box color="label" display="inline" mr="0.5rem">
            Door Lock:
          </Box>
          <Button
            disabled={!hasOccupant}
            selected={locked}
            icon={locked ? "toggle-on" : "toggle-off"}
            content={locked ? "Engaged" : "Disengaged"}
            onClick={() => act('toggleLock')}
          />
          <Button
            disabled={!hasOccupant || locked}
            icon="user-slash"
            content="Eject"
            onClick={() => act('ejectOccupant')}
          />
        </Fragment>
      }>
      {hasOccupant ? (
        <Fragment>
          <Box>
            <LabeledList>
              <LabeledList.Item label="Name">
                {occupant.name}
              </LabeledList.Item>
              <LabeledList.Item label="Health">
                <ProgressBar
                  min={occupant.minHealth}
                  max={occupant.maxHealth}
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
          {context.isDNAInvalid ? (
            <Box color="bad">
              <Icon name="exclamation-circle" />&nbsp;
              The occupant&apos;s DNA structure is ruined beyond recognition,
              please insert a subject with an intact DNA structure.
            </Box>
          ) : (
            <LabeledList>
              <LabeledList.Item label="Radiation">
                <ProgressBar
                  min="0"
                  max="100"
                  value={occupant.radiationLevel / 100}
                  color="average"
                />
              </LabeledList.Item>
              <LabeledList.Item label="Unique Enzymes">
                {data.occupant.uniqueEnzymes
                  ? data.occupant.uniqueEnzymes : (
                    <Box color="bad">
                      <Icon name="exclamation-circle" />&nbsp;
                      Unknown
                    </Box>
                  )}
              </LabeledList.Item>
            </LabeledList>
          )}
        </Fragment>
      ) : (
        <Box color="label">
          Cell unoccupied.
        </Box>
      )}
    </Section>
  );
};

const DNAModifierMain = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    selectedMenuKey,
    hasOccupant,
    occupant,
  } = data;
  if (!hasOccupant) {
    return (
      <Section flexGrow="1">
        <Flex height="100%">
          <Flex.Item
            grow="1"
            align="center"
            textAlign="center"
            color="label">
            <Icon
              name="user-slash"
              mb="0.5rem"
              size="5"
            /><br />
            No occupant in DNA modifier.
          </Flex.Item>
        </Flex>
      </Section>
    );
  } else if (context.isDNAInvalid) {
    return (
      <Section flexGrow="1">
        <Flex height="100%">
          <Flex.Item
            grow="1"
            align="center"
            textAlign="center"
            color="label">
            <Icon
              name="user-slash"
              mb="0.5rem"
              size="5"
            /><br />
            No operation possible on this subject.
          </Flex.Item>
        </Flex>
      </Section>
    );
  }
  let body;
  if (selectedMenuKey === "ui") {
    body = (
      <Fragment>
        <DNAModifierMainUI />
        <DNAModifierMainRadiationEmitter />
      </Fragment>
    );
  } else if (selectedMenuKey === "se") {
    body = (
      <Fragment>
        <DNAModifierMainSE />
        <DNAModifierMainRadiationEmitter />
      </Fragment>
    );
  } else if (selectedMenuKey === "buffer") {
    body = <DNAModifierMainBuffers />;
  } else if (selectedMenuKey === "rejuvenators") {
    body = <DNAModifierMainRejuvenators />;
  }
  return (
    <Section flexGrow="1">
      <Tabs>
        {operations.map((op, i) => (
          <Tabs.Tab
            key={i}
            selected={selectedMenuKey === op[0]}
            onClick={() => act('selectMenuKey', { key: op[0] })}>
            <Icon name={op[2]} />
            {op[1]}
          </Tabs.Tab>
        ))}
      </Tabs>
      {body}
    </Section>
  );
};

const DNAModifierMainUI = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    selectedUIBlock,
    selectedUISubBlock,
    selectedUITarget,
    occupant,
  } = data;
  return (
    <Section title="Modify Unique Identifier" level="2">
      <DNAModifierBlocks
        dnaString={occupant.uniqueIdentity}
        selectedBlock={selectedUIBlock}
        selectedSubblock={selectedUISubBlock}
        blockSize={context.dnaBlockSize}
        action="selectUIBlock"
      />
      <LabeledList>
        <LabeledList.Item label="Target">
          <Knob
            minValue="1"
            maxValue="15"
            stepPixelSize="20"
            value={selectedUITarget}
            format={value => value.toString(16).toUpperCase()}
            ml="0"
            onChange={(e, val) => act('changeUITarget', { value: val })}
          />
        </LabeledList.Item>
      </LabeledList>
      <Button
        icon="radiation"
        content="Irradiate Block"
        mt="0.5rem"
        onClick={() => act('pulseUIRadiation')}
      />
    </Section>
  );
};

const DNAModifierMainSE = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    selectedSEBlock,
    selectedSESubBlock,
    occupant,
  } = data;
  return (
    <Section title="Modify Structural Enzymes" level="2">
      <DNAModifierBlocks
        dnaString={occupant.structuralEnzymes}
        selectedBlock={selectedSEBlock}
        selectedSubblock={selectedSESubBlock}
        blockSize={context.dnaBlockSize}
        action="selectSEBlock"
      />
      <Button
        icon="radiation"
        content="Irradiate Block"
        onClick={() => act('pulseSERadiation')}
      />
    </Section>
  );
};

const DNAModifierMainRadiationEmitter = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    radiationIntensity,
    radiationDuration,
  } = data;
  return (
    <Section title="Radiation Emitter" level="2">
      <LabeledList>
        <LabeledList.Item label="Intensity">
          <Knob
            minValue="1"
            maxValue="10"
            stepPixelSize="20"
            value={radiationIntensity}
            popUpPosition="right"
            ml="0"
            onChange={(e, val) => act('radiationIntensity', { value: val })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Duration">
          <Knob
            minValue="1"
            maxValue="20"
            stepPixelSize="10"
            unit="s"
            value={radiationDuration}
            popUpPosition="right"
            ml="0"
            onChange={(e, val) => act('radiationDuration', { value: val })}
          />
        </LabeledList.Item>
      </LabeledList>
      <Button
        icon="radiation"
        content="Pulse Radiation"
        tooltip="Mutates a random block of either the occupant's UI or SE."
        tooltipPosition="top-right"
        mt="0.5rem"
        onClick={() => act('pulseRadiation')}
      />
    </Section>
  );
};

const DNAModifierMainBuffers = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    buffers,
  } = data;
  let bufferElements = buffers.map((buffer, i) => (
    <DNAModifierMainBuffersElement
      key={i}
      id={i + 1}
      name={"Buffer " + (i + 1)}
      buffer={buffer}
    />
  ));
  return (
    <Fragment>
      <Section title="Buffers" level="2">
        {bufferElements}
      </Section>
      <DNAModifierMainBuffersDisk />
    </Fragment>
  );
};

const DNAModifierMainBuffersElement = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    id,
    name,
    buffer,
  } = props;
  const isInjectorReady = data.isInjectorReady;
  const realName = name + (buffer.data ? ' - ' + buffer.label : '');
  return (
    <Box backgroundColor="rgba(0, 0, 0, 0.33)" mb="0.5rem">
      <Section
        title={realName}
        level="3"
        mx="0"
        lineHeight="18px"
        buttons={
          <Fragment>
            <Button.Confirm
              disabled={!buffer.data}
              icon="trash"
              content="Clear"
              onClick={() => act('bufferOption', {
                option: 'clear',
                id: id,
              })}
            />
            <Button
              disabled={!buffer.data}
              icon="pen"
              content="Rename"
              onClick={() => act('bufferOption', {
                option: 'changeLabel',
                id: id,
              })}
            />
            <Button
              disabled={!buffer.data || !data.hasDisk}
              icon="save"
              content="Export"
              tooltip="Exports this buffer to the currently loaded data disk."
              tooltipPosition="bottom-left"
              onClick={() => act('bufferOption', {
                option: 'saveDisk',
                id: id,
              })}
            />
          </Fragment>
        }>
        <LabeledList>
          <LabeledList.Item label="Write">
            <Button
              icon="arrow-circle-down"
              content="Subject U.I"
              mb="0"
              onClick={() => act('bufferOption', {
                option: 'saveUI',
                id: id,
              })}
            />
            <Button
              icon="arrow-circle-down"
              content="Subject U.I and U.E."
              mb="0"
              onClick={() => act('bufferOption', {
                option: 'saveUIAndUE',
                id: id,
              })}
            />
            <Button
              icon="arrow-circle-down"
              content="Subject S.E."
              mb="0"
              onClick={() => act('bufferOption', {
                option: 'saveSE',
                id: id,
              })}
            />
            <Button
              disabled={!data.hasDisk || !data.disk.data}
              icon="arrow-circle-down"
              content="From Disk"
              mb="0"
              onClick={() => act('bufferOption', {
                option: 'loadDisk',
                id: id,
              })}
            />
          </LabeledList.Item>
          {!!buffer.data && (
            <Fragment>
              <LabeledList.Item label="Subject">
                {buffer.owner || (
                  <Box color="average">
                    Unknown
                  </Box>
                )}
              </LabeledList.Item>
              <LabeledList.Item label="Data Type">
                {buffer.type === "ui"
                  ? "Unique Identifiers"
                  : "Structural Enzymes"}
                {!!buffer.ue && " and Unique Enzymes"}
              </LabeledList.Item>
              <LabeledList.Item label="Transfer to">
                <Button
                  disabled={!isInjectorReady}
                  icon={isInjectorReady ? "syringe" : "spinner"}
                  iconSpin={!isInjectorReady}
                  content="Injector"
                  mb="0"
                  onClick={() => act('bufferOption', {
                    option: 'createInjector',
                    id: id,
                  })}
                />
                <Button
                  disabled={!isInjectorReady}
                  icon={isInjectorReady ? "syringe" : "spinner"}
                  iconSpin={!isInjectorReady}
                  content="Block Injector"
                  mb="0"
                  onClick={() => act('bufferOption', {
                    option: 'createInjector',
                    id: id,
                    block: 1,
                  })}
                />
                <Button
                  icon="user"
                  content="Subject"
                  mb="0"
                  onClick={() => act('bufferOption', {
                    option: 'transfer',
                    id: id,
                  })}
                />
              </LabeledList.Item>
            </Fragment>
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

const DNAModifierMainBuffersDisk = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    hasDisk,
    disk,
  } = data;
  return (
    <Section
      title="Data Disk"
      level="2"
      buttons={
        <Fragment>
          <Button.Confirm
            disabled={!hasDisk || !disk.data}
            icon="trash"
            content="Wipe"
            onClick={() => act('wipeDisk')}
          />
          <Button
            disabled={!hasDisk}
            icon="eject"
            content="Eject"
            onClick={() => act('ejectDisk')}
          />
        </Fragment>
      }>
      {hasDisk ? (
        disk.data ? (
          <LabeledList>
            <LabeledList.Item label="Label">
              {disk.label ? disk.label : "No label"}
            </LabeledList.Item>
            <LabeledList.Item label="Subject">
              {disk.owner
                ? disk.owner : (
                  <Box color="average">
                    Unknown
                  </Box>
                )}
            </LabeledList.Item>
            <LabeledList.Item label="Data Type">
              {disk.type === "ui"
                ? "Unique Identifiers"
                : "Structural Enzymes"}
              {!!disk.ue && " and Unique Enzymes"}
            </LabeledList.Item>
          </LabeledList>
        ) : (
          <Box color="label">
            Disk is blank.
          </Box>
        )
      ) : (
        <Box color="label" textAlign="center" my="1rem">
          <Icon name="save-o" size="4" /><br />
          No disk inserted.
        </Box>
      )}
    </Section>
  );
};

const DNAModifierMainRejuvenators = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    isBeakerLoaded,
    beakerVolume,
    beakerLabel,
  } = data;
  return (
    <Section
      title="Rejuvenators and Beaker"
      level="2"
      buttons={
        <Button
          disabled={!isBeakerLoaded}
          icon="eject"
          content="Eject"
          onClick={() => act('ejectBeaker')}
        />
      }>
      {isBeakerLoaded ? (
        <LabeledList>
          <LabeledList.Item label="Inject">
            {rejuvenatorsDoses.map((a, i) => (
              <Button
                key={i}
                disabled={a > beakerVolume}
                icon="syringe"
                content={a}
                onClick={() => act('injectRejuvenators', {
                  amount: a,
                })}
              />
            ))}
            <Button
              disabled={beakerVolume <= 0}
              icon="syringe"
              content="All"
              onClick={() => act('injectRejuvenators', {
                amount: beakerVolume,
              })}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Beaker">
            <Box mb="0.5rem">
              {beakerLabel ? beakerLabel : "No label"}
            </Box>
            {beakerVolume ? (
              <Box color="good">
                {beakerVolume} unit{beakerVolume === 1 ? "" : "s"} remaining
              </Box>
            ) : (
              <Box color="bad">
                Empty
              </Box>
            )}
          </LabeledList.Item>
        </LabeledList>
      ) : (
        <Box color="label" textAlign="center" my="25%">
          <Icon name="exclamation-triangle" size="4" /><br />
          No beaker loaded.
        </Box>
      )}
    </Section>
  );
};

const DNAModifierIrradiating = (props, context) => {
  return (
    <Dimmer textAlign="center">
      <Icon name="spinner" size="5" spin /><br />
      <Box color="average">
        <h1>
          <Icon name="radiation" />
          &nbsp;Irradiating occupant&nbsp;
          <Icon name="radiation" />
        </h1>
      </Box>
      <Box color="label">
        <h3>
          For {props.duration} second{props.duration === 1 ? "" : "s"}
        </h3>
      </Box>
    </Dimmer>
  );
};

const DNAModifierBlocks = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    dnaString,
    selectedBlock,
    selectedSubblock,
    blockSize,
    action,
  } = props;

  const characters = dnaString.split('');
  let curBlock = 0;
  let dnaBlocks = [];
  for (let block = 0; block < characters.length; block += blockSize) {
    const realBlock = block / blockSize + 1;
    let subBlocks = [];
    for (let subblock = 0; subblock < blockSize; subblock++) {
      const realSubblock = subblock + 1;
      subBlocks.push(
        <Button
          selected={selectedBlock === realBlock
                    && selectedSubblock === realSubblock}
          content={characters[block + subblock]}
          mb="0"
          onClick={() => act(action, {
            block: realBlock,
            subblock: realSubblock,
          })}
        />
      );
    }
    dnaBlocks.push(
      <Flex.Item flex="0 0 16%" mb="1rem">
        <Box
          display="inline-block"
          width="20px"
          height="20px"
          mr="0.5rem"
          lineHeight="20px"
          backgroundColor="rgba(0, 0, 0, 0.33)"
          fontFamily="monospace"
          textAlign="center">
          {realBlock}
        </Box>
        {subBlocks}
      </Flex.Item>
    );
  }
  return (
    <Flex wrap="wrap">
      {dnaBlocks}
    </Flex>
  );
};
