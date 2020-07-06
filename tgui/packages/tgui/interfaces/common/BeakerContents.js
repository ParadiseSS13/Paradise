import { Box } from '../../components';

const formatUnits = a => a + ' unit' + (a === 1 ? '' : 's');

export const BeakerContents = props => {
  const { beakerLoaded, beakerContents = [], buttons } = props;
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
      {beakerContents.map((chemical, i) => (
        <Box key={chemical.name} width="100%">
          <Box color="label" display="inline" verticalAlign="middle">
            {formatUnits(chemical.volume)} of {chemical.name}
          </Box>
          {!!buttons && (
            <Box float="right" display="inline">
              {buttons(chemical, i)}
            </Box>
          )}
          <Box clear="both" />
        </Box>
      ))}
    </Box>
  );
};
