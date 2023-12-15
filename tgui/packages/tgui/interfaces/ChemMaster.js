import { Component, Fragment } from 'inferno';
import { useBackend } from '../backend';
import {
  Box,
  Button,
  Flex,
  Icon,
  Input,
  LabeledList,
  Section,
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

const transferAmounts = [1, 5, 10];

const analyzeModalBodyOverride = (modal, context) => {
  const { act, data } = useBackend(context);
  const result = modal.args.analysis;
  return (
    <Section
      level={2}
      m="-1rem"
      pb="1rem"
      title={data.condi ? 'Condiment Analysis' : 'Reagent Analysis'}
    >
      <Box mx="0.5rem">
        <LabeledList>
          <LabeledList.Item label="Name">{result.name}</LabeledList.Item>
          <LabeledList.Item label="Description">
            {(result.desc || '').length > 0 ? result.desc : 'N/A'}
          </LabeledList.Item>
          {result.blood_type && (
            <Fragment>
              <LabeledList.Item label="Blood type">
                {result.blood_type}
              </LabeledList.Item>
              <LabeledList.Item
                label="Blood DNA"
                className="LabeledList__breakContents"
              >
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
        <ChemMasterBuffer mode={mode} bufferReagents={buffer_reagents} />
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
  const { beaker, beakerReagents, bufferNonEmpty } = props;
  return (
    <Section
      title="Beaker"
      flexGrow="1"
      minHeight="100px"
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
  );
};

const ChemMasterBuffer = (props, context) => {
  const { act } = useBackend(context);
  const { mode, bufferReagents = [] } = props;
  return (
    <Section
      title="Buffer"
      flexGrow="1"
      minHeight="100px"
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
  );
};

const ChemMasterProduction = (props, context) => {
  const { act } = useBackend(context);
  if (!props.bufferNonEmpty && props.isCondiment) {
    return (
      <Section title="Production">
        <Flex
          height="100%"
          style={{
            'padding-top': '20px',
            'padding-bottom': '20px',
          }}
        >
          <Flex.Item grow="1" align="center" textAlign="center" color="label">
            <Icon name="tint-slash" mb="0.5rem" size="5" />
            <br />
            Buffer is empty.
          </Flex.Item>
        </Flex>
      </Section>
    );
  }

  return (
    <Section title="Production">
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
              content={t.name}
              icon={t.icon}
              selected={data.production_mode === i}
              onClick={() => act('set_production_mode', { mode: i })}
            />
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
  const { icon, imageTransform, ...restProps } = props;
  return (
    <Button style={{ padding: 0, 'line-height': 0 }} {...restProps}>
      <span
        style={{
          overflow: 'hidden',
          display: 'inline-block',
          width: '26px',
          height: '26px',
          position: 'relative',
        }}
      >
        <img
          style={{
            '-ms-interpolation-mode': 'nearest-neighbor',
            position: 'absolute',
            top: '50%',
            left: '50%',
            transform: `translate(-50%, -50%) ${imageTransform || ''}`,
            'margin-left': '1px',
          }}
          src={icon}
        />
      </span>
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
      imageTransform="scale(2)"
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
    <Fragment>
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
    </Fragment>
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
    <Section
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
  );
};

modalRegisterBodyOverride('analyze', analyzeModalBodyOverride);
