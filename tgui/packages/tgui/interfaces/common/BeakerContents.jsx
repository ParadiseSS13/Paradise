import { Stack } from 'tgui-core/components';

const formatUnits = (a) => a + ' unit' + (a === 1 ? '' : 's');

/**
 * Displays a beaker's contents
 * @property {object} props
 */
export const BeakerContents = (props) => {
  const { beakerLoaded, beakerContents = [], buttons } = props;

  return (
    <Stack vertical>
      {!beakerLoaded ? (
        <Stack.Item color="label">No beaker loaded.</Stack.Item>
      ) : beakerContents.length === 0 ? (
        <Stack.Item color="label">Beaker is empty.</Stack.Item>
      ) : (
        beakerContents.map((chemical, i) => (
          <Stack key={chemical.name}>
            <Stack.Item key={chemical.name} color="label" grow>
              {formatUnits(chemical.volume)} of {chemical.name}
            </Stack.Item>
            {!!buttons && <Stack.Item>{buttons(chemical, i)}</Stack.Item>}
          </Stack>
        ))
      )}
    </Stack>
  );
};
