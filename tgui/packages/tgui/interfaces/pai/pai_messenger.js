import { useBackend } from "../../backend";
import { ActiveConversation, MessengerList } from "../pda/pda_messenger";

export const pai_messenger = (props, context) => {
  const { act, data } = useBackend(context);
  const { active_convo } = data.app_data;

  if (active_convo) {
    return <ActiveConversation data={data.app_data} />;
  }
  return <MessengerList data={data.app_data} />;
};
