import { useBackend } from "../../backend";
import { AtmosScan } from "../common/AtmosScan";

export const pai_atmosphere = (props, context) => {
  const { act, data } = useBackend(context);

  return <AtmosScan data={data.app_data} />;
};
