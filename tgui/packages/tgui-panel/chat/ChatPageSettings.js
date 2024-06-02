/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { useDispatch, useSelector } from 'common/redux';
import {
  Button,
  Collapsible,
  Divider,
  Input,
  Section,
  Stack,
} from 'tgui/components';
import {
  moveChatPageLeft,
  moveChatPageRight,
  removeChatPage,
  toggleAcceptedType,
  updateChatPage,
} from './actions';
import { MESSAGE_TYPES } from './constants';
import { selectCurrentChatPage } from './selectors';

export const ChatPageSettings = (props, context) => {
  const page = useSelector(context, selectCurrentChatPage);
  const dispatch = useDispatch(context);
  return (
    <Section fill>
      <Stack align="center">
        {!page.isMain && (
          <Stack.Item>
            <Button
              tooltip={'Reorder tab to the left'}
              icon={'angle-left'}
              onClick={() =>
                dispatch(
                  moveChatPageLeft({
                    pageId: page.id,
                  })
                )
              }
            />
          </Stack.Item>
        )}
        <Stack.Item grow ml={0.5}>
          <Input
            width="100%"
            value={page.name}
            onChange={(e, value) =>
              dispatch(
                updateChatPage({
                  pageId: page.id,
                  name: value,
                })
              )
            }
          />
        </Stack.Item>
        {!page.isMain && (
          <Stack.Item ml={0.5}>
            <Button
              tooltip={'Reorder tab to the right'}
              icon={'angle-right'}
              onClick={() =>
                dispatch(
                  moveChatPageRight({
                    pageId: page.id,
                  })
                )
              }
            />
          </Stack.Item>
        )}
        <Stack.Item>
          <Button.Checkbox
            content="Mute"
            checked={page.hideUnreadCount}
            icon={page.hideUnreadCount ? 'bell-slash' : 'bell'}
            tooltip="Disables unread counter"
            onClick={() =>
              dispatch(
                updateChatPage({
                  pageId: page.id,
                  hideUnreadCount: !page.hideUnreadCount,
                })
              )
            }
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            content="Remove"
            icon="times"
            color="red"
            disabled={page.isMain}
            onClick={() =>
              dispatch(
                removeChatPage({
                  pageId: page.id,
                })
              )
            }
          />
        </Stack.Item>
      </Stack>
      <Divider />
      <Section title="Messages to display" level={2}>
        {MESSAGE_TYPES.filter(
          (typeDef) => !typeDef.important && !typeDef.admin
        ).map((typeDef) => (
          <Button.Checkbox
            key={typeDef.type}
            checked={page.acceptedTypes[typeDef.type]}
            onClick={() =>
              dispatch(
                toggleAcceptedType({
                  pageId: page.id,
                  type: typeDef.type,
                })
              )
            }
          >
            {typeDef.name}
          </Button.Checkbox>
        ))}
        <Collapsible mt={1} color="transparent" title="Admin stuff">
          {MESSAGE_TYPES.filter(
            (typeDef) => !typeDef.important && typeDef.admin
          ).map((typeDef) => (
            <Button.Checkbox
              key={typeDef.type}
              checked={page.acceptedTypes[typeDef.type]}
              onClick={() =>
                dispatch(
                  toggleAcceptedType({
                    pageId: page.id,
                    type: typeDef.type,
                  })
                )
              }
            >
              {typeDef.name}
            </Button.Checkbox>
          ))}
        </Collapsible>
      </Section>
    </Section>
  );
};
