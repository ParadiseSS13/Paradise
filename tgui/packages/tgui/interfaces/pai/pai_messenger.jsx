import { useBackend } from '../../backend';
import { ActiveConversation, MessengerList } from '../pda/pda_messenger';

export const pai_messenger = (props) => {
  const { act, data } = useBackend();
  const { active_convo } = data.app_data;

  if (active_convo) {
    return <ActiveConversation data={data.app_data} />;
  }
  return <MessengerList data={data.app_data} />;
};
