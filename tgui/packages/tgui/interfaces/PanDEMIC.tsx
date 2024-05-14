import { BooleanLike } from '../../common/react';
import { InfernoNode } from 'inferno';
import { useBackend } from '../backend';
import {
  Button,
  Flex,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tabs,
} from '../components';
import { Window } from '../layouts';

interface PathogenSymptom {
  name: string;
  stealth: number;
  resistance: number;
  stageSpeed: number;
  transmissibility: number;
}

interface PathogenStrain {
  commonName?: string;
  description?: string;
  bloodDNA?: string;
  bloodType?: string;
  diseaseAgent: string;
  possibleTreatments?: string;
  transmissionRoute?: string;
  symptoms?: PathogenSymptom[];
  isAdvanced: BooleanLike;
}

interface PanDEMICData {
  synthesisCooldown: BooleanLike;
  beakerLoaded: BooleanLike;
  beakerContainsBlood: BooleanLike;
  beakerContainsVirus: BooleanLike;
  selectedStrainIndex: number;
  strains?: PathogenStrain[];
  resistances?: string[];
}

export const PanDEMIC = (props, context) => {
  const { data } = useBackend<PanDEMICData>(context);
  const {
    beakerLoaded,
    beakerContainsBlood,
    beakerContainsVirus,
    resistances = [],
  } = data;

  let emptyPlaceholder;
  if (!beakerLoaded) {
    emptyPlaceholder = <>No container loaded.</>;
  } else if (!beakerContainsBlood) {
    emptyPlaceholder = <>No blood sample found in the loaded container.</>;
  } else if (beakerContainsBlood && !beakerContainsVirus) {
    emptyPlaceholder = <>No disease detected in provided blood sample.</>;
  }

  return (
    <Window width={575} height={510}>
      <Window.Content>
        <Stack fill vertical>
          {emptyPlaceholder && (
            <Section
              title="Container Information"
              buttons={<CommonCultureActions />}
            >
              <NoticeBox>{emptyPlaceholder}</NoticeBox>
              {resistances?.length > 0 && <ResistancesSection />}
            </Section>
          )}
          {!!beakerContainsVirus && <CultureInformationSection />}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const CommonCultureActions = (props, context) => {
  const { act, data } = useBackend<PanDEMICData>(context);
  const { beakerLoaded } = data;
  return (
    <>
      <Button
        icon="eject"
        content="Eject"
        disabled={!beakerLoaded}
        onClick={() => act('eject_beaker')}
      />
      <Button.Confirm
        icon="trash-alt"
        confirmIcon="eraser"
        content="Destroy"
        confirmContent="Destroy"
        disabled={!beakerLoaded}
        onClick={() => act('destroy_eject_beaker')}
      />
    </>
  );
};

const StrainInformation = (
  props: { strain: PathogenStrain; strainIndex: number },
  context
) => {
  const { act, data } = useBackend<PanDEMICData>(context);
  const { beakerContainsVirus } = data;
  const {
    commonName,
    description,
    diseaseAgent,
    bloodDNA,
    bloodType,
    possibleTreatments,
    transmissionRoute,
    isAdvanced,
  } = props.strain;

  const bloodInformation = (
    <>
      <LabeledList.Item label="Blood DNA">
        {!bloodDNA ? (
          'Undetectable'
        ) : (
          <span style={{ 'font-family': "'Courier New', monospace" }}>
            {bloodDNA}
          </span>
        )}
      </LabeledList.Item>
      <LabeledList.Item label="Blood Type">
        {
          <div
            // blood type can sometimes contain a span
            // eslint-disable-next-line react/no-danger
            dangerouslySetInnerHTML={{ __html: bloodType ?? 'Undetectable' }}
          />
        }
      </LabeledList.Item>
    </>
  );

  if (!beakerContainsVirus) {
    return <LabeledList>{bloodInformation}</LabeledList>;
  }

  let nameButtons;
  if (isAdvanced) {
    if (
      commonName !== undefined &&
      commonName !== null &&
      commonName !== 'Unknown'
    ) {
      nameButtons = (
        <Button
          icon="print"
          content="Print Release Forms"
          onClick={() =>
            act('print_release_forms', {
              strain_index: props.strainIndex,
            })
          }
          style={{ 'margin-left': 'auto' }}
        />
      );
    } else {
      nameButtons = (
        <Button
          icon="pen"
          content="Name Disease"
          onClick={() =>
            act('name_strain', { strain_index: props.strainIndex })
          }
          style={{ 'margin-left': 'auto' }}
        />
      );
    }
  }

  return (
    <LabeledList>
      <LabeledList.Item label="Common Name" className="common-name-label">
        <Stack horizontal align="center">
          {commonName ?? 'Unknown'}
          {nameButtons}
        </Stack>
      </LabeledList.Item>
      {description && (
        <LabeledList.Item label="Description">{description}</LabeledList.Item>
      )}
      <LabeledList.Item label="Disease Agent">{diseaseAgent}</LabeledList.Item>
      {bloodInformation}
      <LabeledList.Item label="Spread Vector">
        {transmissionRoute ?? 'None'}
      </LabeledList.Item>
      <LabeledList.Item label="Possible Cures">
        {possibleTreatments ?? 'None'}
      </LabeledList.Item>
    </LabeledList>
  );
};

const StrainInformationSection = (
  props: {
    strain: PathogenStrain;
    strainIndex: number;
    sectionTitle?: string;
    sectionButtons?: InfernoNode | InfernoNode[];
  },
  context
) => {
  const { act, data } = useBackend<PanDEMICData>(context);
  let synthesisCooldown = !!data.synthesisCooldown;
  const appliedSectionButtons = (
    <>
      <Button
        icon={synthesisCooldown ? 'spinner' : 'clone'}
        iconSpin={synthesisCooldown}
        content="Clone"
        disabled={synthesisCooldown}
        onClick={() => act('clone_strain', { strain_index: props.strainIndex })}
      />
      {props.sectionButtons}
    </>
  );

  return (
    <Flex.Item>
      <Section
        title={props.sectionTitle ?? 'Strain Information'}
        buttons={appliedSectionButtons}
      >
        <StrainInformation
          strain={props.strain}
          strainIndex={props.strainIndex}
        />
      </Section>
    </Flex.Item>
  );
};

const CultureInformationSection = (props, context) => {
  const { act, data } = useBackend<PanDEMICData>(context);
  const { selectedStrainIndex, strains } = data;
  const selectedStrain = strains[selectedStrainIndex - 1];

  if (strains.length === 0) {
    return (
      <Stack fill vertical>
        <Section
          title="Container Information"
          buttons={<CommonCultureActions />}
        >
          <NoticeBox>No disease detected in provided blood sample.</NoticeBox>
        </Section>
      </Stack>
    );
  }

  if (strains.length === 1) {
    return (
      <>
        <StrainInformationSection
          strain={strains[0]}
          strainIndex={1}
          sectionButtons={<CommonCultureActions />}
        />
        {strains[0].symptoms?.length > 0 && (
          <StrainSymptomsSection strain={strains[0]} />
        )}
      </>
    );
  }

  const sectionButtons = <CommonCultureActions />;

  return (
    <Stack.Item grow>
      <Section title="Culture Information" fill buttons={sectionButtons}>
        <Flex direction="column" style={{ 'height': '100%' }}>
          <Flex.Item>
            <Tabs>
              {strains.map((strain, i) => (
                <Tabs.Tab
                  key={i}
                  icon="virus"
                  selected={selectedStrainIndex - 1 === i}
                  onClick={() => act('switch_strain', { strain_index: i + 1 })}
                >
                  {strain.commonName ?? 'Unknown'}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Flex.Item>
          <StrainInformationSection
            strain={selectedStrain}
            strainIndex={selectedStrainIndex}
          />
          {selectedStrain.symptoms?.length > 0 && (
            <StrainSymptomsSection
              className="remove-section-bottom-padding"
              strain={selectedStrain}
            />
          )}
        </Flex>
      </Section>
    </Stack.Item>
  );
};

const sum = (values: number[]) => {
  return values.reduce((r, value) => r + value, 0);
};

const StrainSymptomsSection = (props: {
  className?: string;
  strain: PathogenStrain;
}) => {
  const { symptoms } = props.strain;
  return (
    <Flex.Item grow>
      <Section title="Infection Symptoms" fill className={props.className}>
        <Table className="symptoms-table">
          <Table.Row>
            <Table.Cell>Name</Table.Cell>
            <Table.Cell>Stealth</Table.Cell>
            <Table.Cell>Resistance</Table.Cell>
            <Table.Cell>Stage Speed</Table.Cell>
            <Table.Cell>Transmissibility</Table.Cell>
          </Table.Row>
          {symptoms.map((symptom, index) => (
            <Table.Row key={index}>
              <Table.Cell>{symptom.name}</Table.Cell>
              <Table.Cell>{symptom.stealth}</Table.Cell>
              <Table.Cell>{symptom.resistance}</Table.Cell>
              <Table.Cell>{symptom.stageSpeed}</Table.Cell>
              <Table.Cell>{symptom.transmissibility}</Table.Cell>
            </Table.Row>
          ))}
          <Table.Row className="table-spacer" />
          <Table.Row>
            <Table.Cell style={{ 'font-weight': 'bold' }}>Total</Table.Cell>
            <Table.Cell>{sum(symptoms.map((s) => s.stealth))}</Table.Cell>
            <Table.Cell>{sum(symptoms.map((s) => s.resistance))}</Table.Cell>
            <Table.Cell>{sum(symptoms.map((s) => s.stageSpeed))}</Table.Cell>
            <Table.Cell>
              {sum(symptoms.map((s) => s.transmissibility))}
            </Table.Cell>
          </Table.Row>
        </Table>
      </Section>
    </Flex.Item>
  );
};

const VaccineSynthesisIcons = ['flask', 'vial', 'eye-dropper'];

const ResistancesSection = (props, context) => {
  const { act, data } = useBackend<PanDEMICData>(context);
  const { synthesisCooldown, beakerContainsVirus, resistances } = data;
  return (
    <Stack.Item>
      <Section title="Antibodies" fill>
        <Stack horizontal wrap>
          {resistances.map((r, i) => (
            <Stack.Item key={i}>
              <Button
                icon={VaccineSynthesisIcons[i % VaccineSynthesisIcons.length]}
                disabled={!!synthesisCooldown}
                onClick={() =>
                  act('clone_vaccine', { resistance_index: i + 1 })
                }
                mr="0.5em"
              />
              {r}
            </Stack.Item>
          ))}
        </Stack>
      </Section>
    </Stack.Item>
  );
};
