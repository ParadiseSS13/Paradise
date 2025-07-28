import { Box, Section, Table } from 'tgui-core/components';
import { decodeHtmlEntities } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { COLORS } from '../../constants';

const deptCols = COLORS.department;

const HeadRoles = [
  'Captain',
  'Head of Security',
  'Chief Engineer',
  'Chief Medical Officer',
  'Research Director',
  'Head of Personnel',
  'Quartermaster',
];

// Head colour check. Abbreviated to save on 80 char
const HCC = (role) => {
  // Return green if they are the head
  if (HeadRoles.indexOf(role) !== -1) {
    return 'green';
  }

  // Return orange if its a regular person
  return 'orange';
};

// Head bold check. Abbreviated to save on 80 char
const HBC = (role) => {
  // Return true if they are a head
  if (HeadRoles.indexOf(role) !== -1) {
    return true;
  }
};

const ManifestTable = (group) => {
  return (
    group.length > 0 && (
      <Table>
        <Table.Row header color="white">
          <Table.Cell width="50%">Name</Table.Cell>
          <Table.Cell width="35%">Rank</Table.Cell>
          <Table.Cell width="15%">Active</Table.Cell>
        </Table.Row>

        {group.map((person) => (
          <Table.Row color={HCC(person.rank)} key={person.name + person.rank} bold={HBC(person.rank)}>
            <Table.Cell>{decodeHtmlEntities(person.name)}</Table.Cell>
            <Table.Cell>{decodeHtmlEntities(person.rank)}</Table.Cell>
            <Table.Cell>{person.active}</Table.Cell>
          </Table.Row>
        ))}
      </Table>
    )
  );
};

export const CrewManifest = (props) => {
  const { act } = useBackend();
  let finalData;
  if (props.data) {
    finalData = props.data;
  } else {
    let { data } = useBackend();
    finalData = data;
  }
  // HOW TO USE THIS THING
  /*
  	GLOB.data_core.get_manifest_json()
	  data["manifest"] = GLOB.PDA_Manifest
  */
  // And thats it

  const { manifest } = finalData;

  const { heads, sec, eng, med, sci, ser, sup, misc } = manifest;

  return (
    <Box>
      <Section
        title={
          <Box backgroundColor={deptCols.command} m={-1} pt={1} pb={1}>
            <Box ml={1} textAlign="center" fontSize={1.4}>
              Command
            </Box>
          </Box>
        }
        level={2}
      >
        {ManifestTable(heads)}
      </Section>

      <Section
        title={
          <Box backgroundColor={deptCols.security} m={-1} pt={1} pb={1}>
            <Box ml={1} textAlign="center" fontSize={1.4}>
              Security
            </Box>
          </Box>
        }
        level={2}
      >
        {ManifestTable(sec)}
      </Section>

      <Section
        title={
          <Box backgroundColor={deptCols.engineering} m={-1} pt={1} pb={1}>
            <Box ml={1} textAlign="center" fontSize={1.4}>
              Engineering
            </Box>
          </Box>
        }
        level={2}
      >
        {ManifestTable(eng)}
      </Section>

      <Section
        title={
          <Box backgroundColor={deptCols.medical} m={-1} pt={1} pb={1}>
            <Box ml={1} textAlign="center" fontSize={1.4}>
              Medical
            </Box>
          </Box>
        }
        level={2}
      >
        {ManifestTable(med)}
      </Section>

      <Section
        title={
          <Box backgroundColor={deptCols.science} m={-1} pt={1} pb={1}>
            <Box ml={1} textAlign="center" fontSize={1.4}>
              Science
            </Box>
          </Box>
        }
        level={2}
      >
        {ManifestTable(sci)}
      </Section>

      <Section
        title={
          <Box backgroundColor={deptCols.service} m={-1} pt={1} pb={1}>
            <Box ml={1} textAlign="center" fontSize={1.4}>
              Service
            </Box>
          </Box>
        }
        level={2}
      >
        {ManifestTable(ser)}
      </Section>

      <Section
        title={
          <Box backgroundColor={deptCols.supply} m={-1} pt={1} pb={1}>
            <Box ml={1} textAlign="center" fontSize={1.4}>
              Supply
            </Box>
          </Box>
        }
        level={2}
      >
        {ManifestTable(sup)}
      </Section>

      <Section
        title={
          <Box m={-1} pt={1} pb={1}>
            <Box ml={1} textAlign="center" fontSize={1.4}>
              Misc
            </Box>
          </Box>
        }
        level={2}
      >
        {ManifestTable(misc)}
      </Section>
    </Box>
  );
};
