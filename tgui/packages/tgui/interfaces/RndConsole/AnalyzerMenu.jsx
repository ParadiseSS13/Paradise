import { Button, Icon, LabeledList, Section, Table } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend } from '../../backend';

export const AnalyzerMenu = (props) => {
  const { data, act } = useBackend();

  const { tech_levels, loaded_item, linked_analyzer, can_discover } = data;

  if (!linked_analyzer) {
    return <Section title="Analysis Menu">NO SCIENTIFIC ANALYZER LINKED TO CONSOLE</Section>;
  }

  if (!loaded_item) {
    return <Section title="Analysis Menu">No item loaded. Standing by...</Section>;
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
            {!can_discover || (
              <Button
                content="Discover"
                icon="atom"
                onClick={() => {
                  act('discover');
                }}
              />
            )}
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

const TechnologyRow = (props) => {
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
