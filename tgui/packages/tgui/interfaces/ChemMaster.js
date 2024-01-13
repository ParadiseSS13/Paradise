import { Component } from 'inferno';
import { useBackend } from '../backend';
import {
  Box,
  Button,
  Icon,
  Input,
  LabeledList,
  Section,
  Stack,
  Slider,
  Tabs,
} from '../components';
import { Window } from '../layouts';
import { BeakerContents } from './common/BeakerContents';
import {
  ComplexModal,
  modalOpen,
  modalRegisterBodyOverride,
} from './common/ComplexModal';
import { classes } from 'common/react';
import { createLogger } from '../logging';

const logger = createLogger('ChemMaster');

const transferAmounts = [1, 5, 10];

const analyzeModalBodyOverride = (modal, context) => {
  const { act, data } = useBackend(context);
  const result = modal.args.analysis;
  return (
    <Stack.Item>
      <Section title={data.condi ? 'Condiment Analysis' : 'Reagent Analysis'}>
        <Box mx="0.5rem">
          <LabeledList>
            <LabeledList.Item label="Name">{result.name}</LabeledList.Item>
            <LabeledList.Item label="Description">
              {(result.desc || '').length > 0 ? result.desc : 'N/A'}
            </LabeledList.Item>
            {result.blood_type && (
              <>
                <LabeledList.Item label="Blood type">
                  {result.blood_type}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Blood DNA"
                  className="LabeledList__breakContents"
                >
                  {result.blood_dna}
                </LabeledList.Item>
              </>
            )}
            {!data.condi && (
              <Button
                icon={data.printing ? 'spinner' : 'print'}
                disabled={data.printing}
                iconSpin={!!data.printing}
                ml="0.5rem"
                content="Print"
                onClick={() =>
                  act('print', {
                    idx: result.idx,
                    beaker: modal.args.beaker,
                  })
                }
              />
            )}
          </LabeledList>
        </Box>
      </Section>
    </Stack.Item>
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
    <Window width={575} height={650}>
      <ComplexModal />
      <Window.Content>
        <Stack fill vertical>
          <ChemMasterBeaker
            beaker={beaker}
            beakerReagents={beaker_reagents}
            bufferNonEmpty={buffer_reagents.length > 0}
          />
          <ChemMasterBuffer mode={mode} bufferReagents={buffer_reagents} />
          <ChemMasterProduction
            isCondiment={condi}
            bufferNonEmpty={buffer_reagents.length > 0}
          />
          <ChemMasterCustomization />
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ChemMasterBeaker = (props, context) => {
  const { act } = useBackend(context);
  const { beaker, beakerReagents, bufferNonEmpty } = props;
  return (
    <Stack.Item grow>
      <Section
        title="Beaker"
        fill
        scrollable
        buttons={
          bufferNonEmpty ? (
            <Button.Confirm
              icon="eject"
              disabled={!beaker}
              content="Eject and Clear Buffer"
              onClick={() => act('eject')}
            />
          ) : (
            <Button
              icon="eject"
              disabled={!beaker}
              content="Eject and Clear Buffer"
              onClick={() => act('eject')}
            />
          )
        }
      >
        {beaker ? (
          <BeakerContents
            beakerLoaded
            beakerContents={beakerReagents}
            buttons={(chemical, i) => (
              <Box mb={i < beakerReagents.length - 1 && '2px'}>
                <Button
                  content="Analyze"
                  mb="0"
                  onClick={() =>
                    modalOpen(context, 'analyze', {
                      idx: i + 1,
                      beaker: 1,
                    })
                  }
                />
                {transferAmounts.map((am, j) => (
                  <Button
                    key={j}
                    content={am}
                    mb="0"
                    onClick={() =>
                      act('add', {
                        id: chemical.id,
                        amount: am,
                      })
                    }
                  />
                ))}
                <Button
                  content="All"
                  mb="0"
                  onClick={() =>
                    act('add', {
                      id: chemical.id,
                      amount: chemical.volume,
                    })
                  }
                />
                <Button
                  content="Custom.."
                  mb="0"
                  onClick={() =>
                    modalOpen(context, 'addcustom', {
                      id: chemical.id,
                    })
                  }
                />
              </Box>
            )}
          />
        ) : (
          <Box color="label">No beaker loaded.</Box>
        )}
      </Section>
    </Stack.Item>
  );
};

const ChemMasterBuffer = (props, context) => {
  const { act } = useBackend(context);
  const { mode, bufferReagents = [] } = props;
  return (
    <Stack.Item grow>
      <Section
        title="Buffer"
        fill
        scrollable
        buttons={
          <Box color="label">
            Transferring to&nbsp;
            <Button
              icon={mode ? 'flask' : 'trash'}
              color={!mode && 'bad'}
              content={mode ? 'Beaker' : 'Disposal'}
              onClick={() => act('toggle')}
            />
          </Box>
        }
      >
        {bufferReagents.length > 0 ? (
          <BeakerContents
            beakerLoaded
            beakerContents={bufferReagents}
            buttons={(chemical, i) => (
              <Box mb={i < bufferReagents.length - 1 && '2px'}>
                <Button
                  content="Analyze"
                  mb="0"
                  onClick={() =>
                    modalOpen(context, 'analyze', {
                      idx: i + 1,
                      beaker: 0,
                    })
                  }
                />
                {transferAmounts.map((am, i) => (
                  <Button
                    key={i}
                    content={am}
                    mb="0"
                    onClick={() =>
                      act('remove', {
                        id: chemical.id,
                        amount: am,
                      })
                    }
                  />
                ))}
                <Button
                  content="All"
                  mb="0"
                  onClick={() =>
                    act('remove', {
                      id: chemical.id,
                      amount: chemical.volume,
                    })
                  }
                />
                <Button
                  content="Custom.."
                  mb="0"
                  onClick={() =>
                    modalOpen(context, 'removecustom', {
                      id: chemical.id,
                    })
                  }
                />
              </Box>
            )}
          />
        ) : (
          <Box color="label">Buffer is empty.</Box>
        )}
      </Section>
    </Stack.Item>
  );
};

const ChemMasterProduction = (props, context) => {
  const { act } = useBackend(context);
  if (!props.bufferNonEmpty && props.isCondiment) {
    return (
      <Stack.Item>
        <Section title="Production">
          <Stack fill>
            <Stack.Item grow align="center" textAlign="center" color="label">
              <Icon name="tint-slash" mb="0.5rem" size="5" />
              <br />
              Buffer is empty.
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    );
  }

  return (
    <Stack.Item>
      <Section fill title="Production">
        {!props.isCondiment ? (
          <ChemMasterProductionChemical />
        ) : (
          <ChemMasterProductionCondiment />
        )}
      </Section>
    </Stack.Item>
  );
};

const ChemMasterProductionChemical = (props, context) => {
  const { act, data } = useBackend(context);
  const tabs = [
    {
      'name': 'Pills',
      'icon': 'pills',
    },
    {
      'name': 'Patches',
      'icon': 'plus-square',
    },
    {
      'name': 'Bottles',
      'icon': 'wine-bottle',
    },
  ];
  const decideTab = (mode) => {
    switch (mode) {
      case 1:
        return <ChemMasterProductionPills />;
      case 2:
        return <ChemMasterProductionPatches />;
      case 3:
        return <ChemMasterProductionBottles />;
      default:
        return 'UNKNOWN INTERFACE';
    }
  };
  return (
    <>
      <Tabs>
        {tabs.map((t, i) => {
          i += 1;
          return (
            <Tabs.Tab
              key={i}
              icon={t.icon}
              selected={data.production_mode === i}
              onClick={() => act('set_production_mode', { mode: i })}
            >
              {t.name}
            </Tabs.Tab>
          );
        })}
      </Tabs>
      {decideTab(data.production_mode)}
    </>
  );
};

class ChemMasterNameInput extends Component {
  constructor() {
    super();

    this.handleMouseUp = (e) => {
      const { placeholder, onMouseUp } = this.props;

      // Middle-click button
      if (e.button === 1) {
        e.target.value = placeholder;
        e.target.select();
      }

      if (onMouseUp) {
        onMouseUp(e);
      }
    };
  }

  render() {
    const { data } = useBackend(this.context);
    const { maxnamelength } = data;

    return (
      <Input
        maxLength={maxnamelength}
        onMouseUp={this.handleMouseUp}
        {...this.props}
      />
    );
  }
}

const ChemMasterProductionCommon = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    children,
    maxQuantity,
    medicineName,
    placeholderName,
    productionType,
    quantity,
  } = props;
  const { buffer_reagents = [] } = data;
  return (
    <LabeledList>
      {children}
      <LabeledList.Item label="Quantity">
        <Slider
          value={quantity}
          minValue={1}
          maxValue={maxQuantity}
          onChange={(e, value) =>
            act(`set_${productionType}_amount`, { amount: value })
          }
        />
      </LabeledList.Item>
      <LabeledList.Item label="Name">
        <ChemMasterNameInput
          fluid
          value={medicineName}
          placeholder={placeholderName}
          onChange={(e, value) =>
            act(`set_${productionType}_name`, { name: value })
          }
        />
      </LabeledList.Item>
      <LabeledList.Item>
        <Button
          fluid
          content="Create"
          color="green"
          disabled={buffer_reagents.length <= 0}
          onClick={() => act(`create_${productionType}`)}
        />
      </LabeledList.Item>
    </LabeledList>
  );
};

const SpriteStyleButton = (props, context) => {
  const { icon, ...restProps } = props;
  return (
    <Button style={{ padding: 0, 'line-height': 0 }} {...restProps}>
      <Box className={classes(['chem_master32x32', icon])} />
    </Button>
  );
};

const ChemMasterProductionPills = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    maxpills,
    pillamount,
    pillname,
    pillplaceholdername,
    pillsprite,
    pillstyles,
  } = data;
  const style_buttons = pillstyles.map(({ id, sprite }) => (
    <SpriteStyleButton
      key={id}
      icon={sprite}
      color="translucent"
      onClick={() => act('set_pills_style', { style: id })}
      selected={pillsprite === id}
    />
  ));
  return (
    <ChemMasterProductionCommon
      maxQuantity={maxpills}
      medicineName={pillname}
      placeholderName={pillplaceholdername}
      productionType="pills"
      quantity={pillamount}
    >
      <LabeledList.Item label="Style">{style_buttons}</LabeledList.Item>
    </ChemMasterProductionCommon>
  );
};

const ChemMasterProductionPatches = (props, context) => {
  const { act, data } = useBackend(context);
  const { maxpatches, patchamount, patchname, patchplaceholdername } = data;
  return (
    <ChemMasterProductionCommon
      maxQuantity={maxpatches}
      medicineName={patchname}
      placeholderName={patchplaceholdername}
      productionType="patches"
      quantity={patchamount}
    />
  );
};

const ChemMasterProductionBottles = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    bottlesprite,
    maxbottles,
    bottleamount,
    bottlename,
    bottleplaceholdername,
    bottlestyles,
  } = data;
  const style_buttons = bottlestyles.map(({ id, sprite }) => (
    <SpriteStyleButton
      key={id}
      icon={sprite}
      color="translucent"
      onClick={() => act('set_bottles_style', { style: id })}
      selected={bottlesprite === id}
    />
  ));
  return (
    <ChemMasterProductionCommon
      maxQuantity={maxbottles}
      medicineName={bottlename}
      placeholderName={bottleplaceholdername}
      productionType="bottles"
      quantity={bottleamount}
    >
      <LabeledList.Item label="Style">{style_buttons}</LabeledList.Item>
    </ChemMasterProductionCommon>
  );
};

const ChemMasterProductionCondiment = (props, context) => {
  const { act } = useBackend(context);
  return (
    <>
      <Button
        icon="box"
        content="Create condiment pack (10u max)"
        mb="0.5rem"
        onClick={() => modalOpen(context, 'create_condi_pack')}
      />
      <br />
      <Button
        icon="wine-bottle"
        content="Create bottle (50u max)"
        mb="0"
        onClick={() => act('create_condi_bottle')}
      />
    </>
  );
};

const ChemMasterCustomization = (props, context) => {
  const { act, data } = useBackend(context);
  const { loaded_pill_bottle_style, containerstyles, loaded_pill_bottle } =
    data;

  const style_button_size = { width: '20px', height: '20px' };
  const style_buttons = containerstyles.map(({ color, name }) => {
    let selected = loaded_pill_bottle_style === color;
    return (
      <Button
        key={color}
        style={{
          position: 'relative',
          width: style_button_size.width,
          height: style_button_size.height,
        }}
        onClick={() => act('set_container_style', { style: color })}
        icon={selected && 'check'}
        iconStyle={{
          position: 'relative',
          'z-index': 1,
        }}
        tooltip={name}
        tooltipPosition="top"
      >
        {/* Required. Removing this causes non-selected elements to flow up */}
        {!selected && <div style={{ display: 'inline-block' }} />}
        <span
          className="Button"
          style={{
            display: 'inline-block',
            position: 'absolute',
            top: 0,
            left: 0,
            margin: 0,
            padding: 0,
            width: style_button_size.width,
            height: style_button_size.height,
            'background-color': color,
            opacity: 0.6,
            filter: 'alpha(opacity=60)',
          }}
        />
      </Button>
    );
  });
  return (
    <Stack.Item>
      <Section
        fill
        title="Container Customization"
        buttons={
          <Button
            icon="eject"
            disabled={!loaded_pill_bottle}
            content="Eject Container"
            onClick={() => act('ejectp')}
          />
        }
      >
        {!loaded_pill_bottle ? (
          <Box color="label">No pill bottle or patch pack loaded.</Box>
        ) : (
          <LabeledList>
            <LabeledList.Item label="Style" style={{ position: 'relative' }}>
              <Button
                style={{
                  width: style_button_size.width,
                  height: style_button_size.height,
                }}
                icon="tint-slash"
                onClick={() => act('clear_container_style')}
                selected={!loaded_pill_bottle_style}
                tooltip="Default"
                tooltipPosition="top"
              />
              {style_buttons}
            </LabeledList.Item>
          </LabeledList>
        )}
      </Section>
    </Stack.Item>
  );
};

modalRegisterBodyOverride('analyze', analyzeModalBodyOverride);
