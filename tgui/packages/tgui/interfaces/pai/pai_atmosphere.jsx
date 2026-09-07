import { useBackend } from '../../backend';
import { AtmosScan } from '../common/AtmosScan';

export const pai_atmosphere = (props) => {
  const { act, data } = useBackend();

  return <AtmosScan aircontents={data.app_data.aircontents} />;
};
