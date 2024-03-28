import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Button, LabeledList, Section, ProgressBar } from '../components';
import { Window } from '../layouts';

type MintData = {
  processing: BooleanLike;
};

export const CoinMint = (props, context) => {
  const { act, data } = useBackend<MintData>(context);
  const { processing } = data;
  return (
    <Window width={250} height={400}>
      <Window.Content>
        <Section />
      </Window.Content>
    </Window>
  );
};
