import { useBackend } from "../../backend";
import { SimpleRecords } from "../common/SimpleRecords";

export const pai_secrecords = (props, context) => {
  const { data } = useBackend(context);
  return <SimpleRecords data={data.app_data} recordType="SEC" />;
};
