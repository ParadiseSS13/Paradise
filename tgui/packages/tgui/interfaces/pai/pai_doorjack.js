import { useBackend } from '../../backend';
import { LabeledList, Button, ProgressBar, Box } from '../../components';

export const pai_doorjack = (props, context) => {
  const { act, data } = useBackend(context);
  const { cable, machine, inprogress, progress, aborted } = data.app_data;

  let cableContent;

  if (machine) {
    cableContent = <Button selected content="Connected" />;
  } else {
    cableContent = (
      <Button content={cable ? 'Extended' : 'Retracted'} color={cable ? 'orange' : null} onClick={() => act('cable')} />
    );
  }

  let hackContent;
  if (machine) {
    hackContent = (
      <LabeledList.Item label="Hack">
        <ProgressBar
          ranges={{
            good: [67, Infinity],
            average: [33, 67],
            bad: [-Infinity, 33],
          }}
          value={progress}
          maxValue={100}
        />
        {inprogress ? (
          <Button mt={1} color="red" content="Abort" onClick={() => act('cancel')} />
        ) : (
          <Button mt={1} content="Start" onClick={() => act('jack')} />
        )}
      </LabeledList.Item>
    );
  }

  return (
    <LabeledList>
      <LabeledList.Item label="Cable">{cableContent}</LabeledList.Item>
      {hackContent}
    </LabeledList>
  );
};
