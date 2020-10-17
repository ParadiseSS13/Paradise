import { useBackend } from "../../backend";
import { AtmosScan } from '../common/AtmosScan';

export const pda_atmos_scan = (props, context) => {
  const { data } = useBackend(context);
  return <AtmosScan data={data} />;
};
