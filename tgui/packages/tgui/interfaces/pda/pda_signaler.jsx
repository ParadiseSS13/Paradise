import { useBackend } from '../../backend';
import { Signaler } from '../common/Signaler';

export const pda_signaler = (props) => {
  const { act, data } = useBackend();
  return <Signaler data={data} />;
};
