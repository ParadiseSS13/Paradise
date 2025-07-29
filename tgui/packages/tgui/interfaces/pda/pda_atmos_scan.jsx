import { useBackend } from '../../backend';
import { AtmosScan } from '../common/AtmosScan';

export const pda_atmos_scan = (props) => {
  const { data } = useBackend();
  return <AtmosScan aircontents={data.aircontents} />;
};
