import { Box } from '../../components';

const formatUnits = a => a + ' unit' + (a === 1 ? '' : 's');

export const BeakerContents = props => {
  const { beakerLoaded, beakerContents } = props;
  return (
    <Box>
      {!beakerLoaded && (
        <Box color="label">
          No beaker loaded.
        </Box>
      ) || beakerContents.length === 0 && (
        <Box color="label">
          Beaker is empty.
        </Box>
      )}
      {beakerContents.map(chemical => (
        <Box key={chemical.name} color="label">
          {formatUnits(chemical.volume)} of {chemical.name}
        </Box>
      ))}
    </Box>
  );
};
