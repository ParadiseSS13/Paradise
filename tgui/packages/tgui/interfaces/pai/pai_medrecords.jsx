import { useBackend } from '../../backend';
import { SimpleRecords } from '../common/SimpleRecords';

export const pai_medrecords = (props) => {
  const { data } = useBackend();
  return <SimpleRecords data={data.app_data} recordType="MED" />;
};
