import { useBackend } from '../../backend';
import { SimpleRecords } from '../common/SimpleRecords';

export const pda_medical = (props) => {
  const { data } = useBackend();
  return <SimpleRecords data={data} recordType="MED" />;
};
