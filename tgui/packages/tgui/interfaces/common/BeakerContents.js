import { Stack } from '../../components';
const PropTypes = require('prop-types');

const formatUnits = (a) => a + ' unit' + (a === 1 ? '' : 's');

/**
 * Displays a beaker's contents
 * @property {object} props
 */
export const BeakerContents = (props) => {
  const { beakerLoaded, beakerContents = [], buttons } = props;
  return (
    <Stack vertical>
      {(!beakerLoaded && <Stack.Item color="label">No beaker loaded.</Stack.Item>) ||
        (beakerContents.length === 0 && <Stack.Item color="label">Beaker is empty.</Stack.Item>)}
      {beakerContents.map((chemical, i) => (
        <Stack key={chemical.name}>
          <Stack.Item key={chemical.name} color="label" grow>
            {formatUnits(chemical.volume)} of {chemical.name}
          </Stack.Item>
          {!!buttons && <Stack.Item>{buttons(chemical, i)}</Stack.Item>}
        </Stack>
      ))}
    </Stack>
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
