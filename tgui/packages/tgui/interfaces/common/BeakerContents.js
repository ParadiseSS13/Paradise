import { Box } from '../../components';
const PropTypes = require('prop-types');

const formatUnits = a => a + ' unit' + (a === 1 ? '' : 's');

/**
 * Displays a beaker's contents
 * @property {object} props
 */
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

BeakerContents.propTypes = {
  /**
   * Whether there is a loaded beaker or not
   */
  beakerLoaded: PropTypes.bool,
  /**
   * The reagents in the beaker
   */
  beakerContents: PropTypes.array,
  /**
   * The buttons to display next to each reagent line
   */
  buttons: PropTypes.arrayOf(PropTypes.element),
};
