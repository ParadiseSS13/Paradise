import { useBackend } from "../../backend";
import { SimpleRecords } from "../common/SimpleRecords";

export const pda_security = (props, context) => {
  const { data } = useBackend(context);
  return <SimpleRecords data={data} recordType="SEC" />;
};
