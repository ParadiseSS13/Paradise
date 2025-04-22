import { useBackend } from '../../backend';
import { AtmosScan } from '../common/AtmosScan';

export const pai_atmosphere = (props) => {
  const { act, data } = useBackend();

  return <AtmosScan data={data.app_data} />;
};
