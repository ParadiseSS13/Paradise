import { Fragment } from 'inferno';
import { useBackend } from "../backend";
import { Box, Button, Flex, Icon, LabeledList, Section } from "../components";
import { Window } from "../layouts";
import { BeakerContents } from './common/BeakerContents';
import { ComplexModal, modalOpen, modalRegisterBodyOverride } from './common/ComplexModal';

const transferAmounts = [1, 5, 10];
const bottleStyles = [
  "bottle.png",
  "small_bottle.png",
  "wide_bottle.png",
  "round_bottle.png",
  "reagent_bottle.png",
];

const analyzeModalBodyOverride = (modal, context) => {
  const { act, data } = useBackend(context);
  const result = modal.args.analysis;
  return (
    <Section
      level={2}
      m="-1rem"
      pb="1rem"
      title={data.condi ? "Condiment Analysis" : "Reagent Analysis"}>
      <Box mx="0.5rem">
        <LabeledList>
          <LabeledList.Item label="Name">
            {result.name}
          </LabeledList.Item>
          <LabeledList.Item label="Description">
            {(result.desc || "").length > 0 ? result.desc : "N/A"}
          </LabeledList.Item>
          {result.blood_type && (
            <Fragment>
              <LabeledList.Item label="Blood type">
                {result.blood_type}
              </LabeledList.Item>
              <LabeledList.Item
                label="Blood DNA"
                className="LabeledList__breakContents">
                {result.blood_dna}
              </LabeledList.Item>
            </Fragment>
          )}
          {!data.condi && (
            <Button
              icon={data.printing ? 'spinner' : 'print'}
              disabled={data.printing}
              iconSpin={!!data.printing}
              ml="0.5rem"
              content="Print"
              onClick={() => act('print', {
                idx: result.idx,
                beaker: modal.args.beaker,
              })}
            />
          )}
        </LabeledList>
      </Box>
    </Section>
  );
};

export const ChemMaster = (props, context) => {
  const { data } = useBackend(context);
  const {
    condi,
    beaker,
    beaker_reagents = [],
    buffer_reagents = [],
    mode,
  } = data;
  return (
    <Window resizable>
      <ComplexModal />
      <Window.Content scrollable className="Layout__content--flexColumn">
        <ChemMasterBeaker
          beaker={beaker}
          beakerReagents={beaker_reagents}
          bufferNonEmpty={buffer_reagents.length > 0}
        />
        <ChemMasterBuffer
          mode={mode}
          bufferReagents={buffer_reagents}
        />
        <ChemMasterProduction
          isCondiment={condi}
          bufferNonEmpty={buffer_reagents.length > 0}
        />
        <ChemMasterCustomization />
      </Window.Content>
    </Window>
  );
};

const ChemMasterBeaker = (props, context) => {
  const { act } = useBackend(context);
  const {
    beaker,
    beakerReagents,
    bufferNonEmpty,
  } = props;
  return (
    <Section
      title="Beaker"
      flexGrow="0"
      flexBasis="300px"
      buttons={bufferNonEmpty
        ? <Button.Confirm
          icon="eject"
          disabled={!beaker}
          content="Eject and Clear Buffer"
          onClick={() => act('eject')}
        />
        : <Button
          icon="eject"
          disabled={!beaker}
          content="Eject and Clear Buffer"
          onClick={() => act('eject')}
        />}>
      {beaker
        ? <BeakerContents
          beakerLoaded
          beakerContents={beakerReagents}
          buttons={(chemical, i) => (
            <Box mb={(i < beakerReagents.length - 1) && "2px"}>
              <Button
                content="Analyze"
                mb="0"
                onClick={() => modalOpen(context, 'analyze', {
                  idx: i + 1,
                  beaker: 1,
                })}
              />
              {transferAmounts.map((am, j) =>
                (<Button
                  key={j}
                  content={am}
                  mb="0"
                  onClick={() => act('add', {
                    id: chemical.id,
                    amount: am,
                  })}
                />)
              )}
              <Button
                content="All"
                mb="0"
                onClick={() => act('add', {
                  id: chemical.id,
                  amount: chemical.volume,
                })}
              />
              <Button
                content="Custom.."
                mb="0"
                onClick={() => modalOpen(context, 'addcustom', {
                  id: chemical.id,
                })}
              />
            </Box>
          )}
        />
        : (
          <Box color="label">
            No beaker loaded.
          </Box>
        )}
    </Section>
  );
};

const ChemMasterBuffer = (props, context) => {
  const { act } = useBackend(context);
  const {
    mode,
    bufferReagents = [],
  } = props;
  return (
    <Section
      title="Buffer"
      flexGrow="0"
      flexBasis="300px"
      buttons={
        <Box color="label">
          Transferring to&nbsp;
          <Button
            icon={mode ? "flask" : "trash"}
            color={!mode && "bad"}
            content={mode ? "Beaker" : "Disposal"}
            onClick={() => act('toggle')}
          />
        </Box>
      }>
      {(bufferReagents.length > 0)
        ? <BeakerContents
          beakerLoaded
          beakerContents={bufferReagents}
          buttons={(chemical, i) => (
            <Box mb={(i < bufferReagents.length - 1) && "2px"}>
              <Button
                content="Analyze"
                mb="0"
                onClick={() => modalOpen(context, 'analyze', {
                  idx: i + 1,
                  beaker: 0,
                })}
              />
              {transferAmounts.map((am, i) =>
                (<Button
                  key={i}
                  content={am}
                  mb="0"
                  onClick={() => act('remove', {
                    id: chemical.id,
                    amount: am,
                  })}
                />)
              )}
              <Button
                content="All"
                mb="0"
                onClick={() => act('remove', {
                  id: chemical.id,
                  amount: chemical.volume,
                })}
              />
              <Button
                content="Custom.."
                mb="0"
                onClick={() => modalOpen(context, 'removecustom', {
                  id: chemical.id,
                })}
              />
            </Box>
          )}
        />
        : (
          <Box color="label">
            Buffer is empty.
          </Box>
        )}
    </Section>
  );
};

const ChemMasterProduction = (props, context) => {
  const { act } = useBackend(context);
  if (!props.bufferNonEmpty) {
    return (
      <Section
        title="Production"
        height="100%"
        flexGrow="1">
        <Flex height="100%">
          <Flex.Item
            grow="1"
            align="center"
            textAlign="center"
            color="label">
            <Icon
              name="tint-slash"
              mb="0.5rem"
              size="5"
            /><br />
            Buffer is empty.
          </Flex.Item>
        </Flex>
      </Section>
    );
  }

  return (
    <Section title="Production" height="100%" flexGrow="1">
      {!props.isCondiment ? (
        <ChemMasterProductionChemical />
      ) : (
        <ChemMasterProductionCondiment />
      )}
    </Section>
  );
};

const ChemMasterProductionChemical = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <LabeledList>
      <LabeledList.Item label="Pills">
        <Button
          icon="circle"
          content="One (100u max)"
          onClick={() => modalOpen(context, 'create_pill')}
        />
        <Button
          icon="plus-circle"
          content="Multiple"
          mx="0.5rem"
          onClick={() => modalOpen(context, 'create_pill_multiple')}
        />
        <Button
          onClick={() => modalOpen(context, 'change_pill_style')}>
          <div style={
            "display: inline-block;"
            + "width: 16px;"
            + "height: 16px;"
            + "vertical-align: middle;"
            + "background: url(pill" + data.pillsprite + ".png);"
            + "background-size: 200%;"
            + "background-position: left -10px bottom -6px;"
          } />
          Style
        </Button>
      </LabeledList.Item>
      <LabeledList.Item label="Patches">
        <Button
          icon="square"
          content="One (30u max)"
          mr="0.5rem"
          onClick={() => modalOpen(context, 'create_patch')}
        />
        <Button
          icon="plus-square"
          content="Multiple"
          onClick={() => modalOpen(context, 'create_patch_multiple')}
        />
      </LabeledList.Item>
      <LabeledList.Item label="Bottle">
        <Button
          icon="wine-bottle"
          content="Create bottle (50u max)"
          mr="0.5rem"
          mb="0.5rem"
          onClick={() => modalOpen(context, 'create_bottle')}
        />
        <Button
          mb="0.5rem"
          onClick={() => modalOpen(context, 'change_bottle_style')}>
          <div style={
            "display: inline-block;"
            + "width: 16px;"
            + "height: 16px;"
            + "vertical-align: middle;"
            + "background: url(" + bottleStyles[data.bottlesprite - 1] + ");"
            + "background-size: 200%;"
            + "background-position: left -10px bottom -6px;"
          } />
          Style
        </Button>
      </LabeledList.Item>
    </LabeledList>
  );
};

const ChemMasterProductionCondiment = (props, context) => {
  const { act } = useBackend(context);
  return (
    <Fragment>
      <Button
        icon="box"
        content="Create condiment pack (10u max)"
        mb="0.5rem"
        onClick={() => modalOpen(context, 'create_condi_pack')}
      /><br />
      <Button
        icon="wine-bottle"
        content="Create bottle (50u max)"
        mb="0"
        onClick={() => act('create_condi_bottle')}
      />
    </Fragment>
  );
};

const ChemMasterCustomization = (props, context) => {
  const { act, data } = useBackend(context);
  if (!data.loaded_pill_bottle) {
    return (
      <Section title="Container Customization">
        <Box color="label">
          No pill bottle or patch pack loaded.
        </Box>
      </Section>
    );
  }

  return (
    <Section title="Container Customization">
      <Button
        disabled={!data.loaded_pill_bottle}
        icon="eject"
        content={data.loaded_pill_bottle
          ? data.loaded_pill_bottle_name
          : "None loaded"}
        onClick={() => act('ejectp')}
      />
      <Button
        disabled={!data.loaded_pill_bottle}
        icon="palette"
        content="Change wrapper"
        mb="0"
        onClick={() => modalOpen(context, 'change_pill_bottle_style')}
      />
    </Section>
  );
};

modalRegisterBodyOverride('analyze', analyzeModalBodyOverride);
