import { Stack } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

const formatUnits = (a: number) => a + ' unit' + (a === 1 ? '' : 's');

type BeakerReagent = {
  name: string;
  id: string;
  volume: number;
};

type BeakerContentsProps = {
  beakerLoaded: BooleanLike;
  beakerContents: BeakerReagent[];
  buttons: (chemical: BeakerReagent, idx: number) => React.JSX.Element;
};

/**
 * Displays a beaker's contents
 */
export const BeakerContents = (props: BeakerContentsProps) => {
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
