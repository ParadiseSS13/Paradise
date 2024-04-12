import { decodeHtmlEntities } from 'common/string';
import { useBackend } from '../backend';
import { Section, Stack } from '../components';
import { Window } from '../layouts';

type NoticeData = {
  papers: Paper[];
};

type Paper = {
  name: string;
  contents: string;
  ref: string;
};

export const Noticeboard = (props, context) => {
  const { act, data } = useBackend<NoticeData>(context);
  const { papers } = data;
  return (
    <Window width={600} height={300} theme={'noticeboard'}>
      <Window.Content>
        <Stack fill>
          {papers.map((paper) => (
            <Stack.Item
              key={paper.ref}
              align={'center'}
              width={'22.45%'}
              height={'85%'}
              onClick={() => act('interact', { paper: paper.ref })}
              onContextMenu={(event) => {
                event.preventDefault();
                act('showFull', { paper: paper.ref });
              }}
            >
              <Section fill scrollable fontSize={0.75} title={paper.name}>
                {decodeHtmlEntities(paper.contents)}
              </Section>
            </Stack.Item>
          ))}
        </Stack>
      </Window.Content>
    </Window>
  );
};
