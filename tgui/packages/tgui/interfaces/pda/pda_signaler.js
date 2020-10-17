import { useBackend } from "../../backend";
import { Signaler } from "../common/Signaler";

export const pda_signaler = (props, context) => {
  const { act, data } = useBackend(context);
  return <Signaler data={data} />;
};
