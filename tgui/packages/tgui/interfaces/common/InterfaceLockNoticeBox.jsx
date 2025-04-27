import { Button, Flex, NoticeBox } from 'tgui-core/components';

import { useBackend } from '../../backend';

/**
 * This component by expects the following fields to be returned
 * from ui_data:
 *
 * - siliconUser: boolean
 * - locked: boolean
 * - normallyLocked: boolean
 *
 * And expects the following ui_act action to be implemented:
 *
 * - lock - for toggling the lock as a silicon user.
 *
 * All props can be redefined if you want custom behavior, but
 * it's preferred to stick to defaults.
 */
export const InterfaceLockNoticeBox = (props) => {
  const { act, data } = useBackend();
  const {
    siliconUser = data.siliconUser,
    locked = data.locked,
    normallyLocked = data.normallyLocked,
    onLockStatusChange = () => act('lock'),
    accessText = 'an ID card',
  } = props;
  // For silicon users
  if (siliconUser) {
    return (
      <NoticeBox color={siliconUser && 'grey'}>
        <Flex align="center">
          <Flex.Item>Interface lock status:</Flex.Item>
          <Flex.Item grow="1" />
          <Flex.Item>
            <Button
              m="0"
              color={normallyLocked ? 'red' : 'green'}
              icon={normallyLocked ? 'lock' : 'unlock'}
              content={normallyLocked ? 'Locked' : 'Unlocked'}
              onClick={() => {
                if (onLockStatusChange) {
                  onLockStatusChange(!locked);
                }
              }}
            />
          </Flex.Item>
        </Flex>
      </NoticeBox>
    );
  }
  // For everyone else
  return (
    <NoticeBox>
      Swipe {accessText} to {locked ? 'unlock' : 'lock'} this interface.
    </NoticeBox>
  );
};
