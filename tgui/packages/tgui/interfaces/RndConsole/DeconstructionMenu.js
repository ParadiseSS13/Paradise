import { classes } from 'common/react';
import { useBackend } from '../../backend';
import { Button, Icon, LabeledList, Section, Table } from '../../components';

export const DeconstructionMenu = (props, context) => {
  const { data, act } = useBackend(context);

  const { tech_levels, loaded_item, linked_destroy } = data;

  if (!linked_destroy) {
    return <Section title="Deconstruction Menu">NO DESTRUCTIVE ANALYZER LINKED TO CONSOLE</Section>;
  }

  if (!loaded_item) {
    return <Section title="Deconstruction Menu">No item loaded. Standing by...</Section>;
  }

  return (
    <>
      <Section
        title="Object Analysis"
        buttons={
          <>
            <Button
              content="Deconstruct"
              icon="microscope"
              onClick={() => {
                act('deconstruct');
              }}
            />
            <Button
              content="Eject"
              icon="eject"
              onClick={() => {
                act('eject_item');
              }}
            />
          </>
        }
      >
        <LabeledList>
          <LabeledList.Item label="Name">{loaded_item.name}</LabeledList.Item>
        </LabeledList>
      </Section>
      <Section>
        <Table id="research-levels">
          <Table.Row>
            <Table.Cell />
            <Table.Cell header>Research Field</Table.Cell>
            <Table.Cell header>Current Level</Table.Cell>
            <Table.Cell header>Object Level</Table.Cell>
            <Table.Cell header>New Level</Table.Cell>
          </Table.Row>
          {tech_levels.map((techLevel) => (
            <TechnologyRow key={techLevel.id} techLevel={techLevel} />
          ))}
        </Table>
      </Section>
    </>
  );
};

const TechnologyRow = (props, context) => {
  const {
    techLevel: { name, desc, level, object_level, ui_icon },
  } = props;
  const objectLevelDefined = object_level !== undefined && object_level !== null;
  const newLevel = objectLevelDefined ? (object_level >= level ? Math.max(object_level, level + 1) : level) : level;
  return (
    <Table.Row>
      <Table.Cell>
        <Button icon="circle-info" tooltip={desc} />
      </Table.Cell>
      <Table.Cell>
        <Icon name={ui_icon} /> {name}
      </Table.Cell>
      <Table.Cell>{level}</Table.Cell>
      {objectLevelDefined ? (
        <Table.Cell>{object_level}</Table.Cell>
      ) : (
        <Table.Cell className="research-level-no-effect">-</Table.Cell>
      )}
      <Table.Cell className={classes([newLevel !== level && 'upgraded-level'])}>{newLevel}</Table.Cell>
    </Table.Row>
  );
};
