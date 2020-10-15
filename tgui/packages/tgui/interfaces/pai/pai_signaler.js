import { useBackend } from "../../backend";
import { Signaler } from "../common/Signaler";

export const pai_signaler = (props, context) => {
  const { act, data } = useBackend(context);
  return <Signaler data={data.app_data} />;
};
