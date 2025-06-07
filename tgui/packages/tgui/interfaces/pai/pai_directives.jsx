import { Box, Button, LabeledList } from 'tgui-core/components';

import { useBackend } from '../../backend';

export const pai_directives = (props) => {
  const { act, data } = useBackend();
  const { master, dna, prime, supplemental } = data.app_data;

  return (
    <Box>
      <LabeledList>
        <LabeledList.Item label="Master">{master ? master + ' (' + dna + ')' : 'None'}</LabeledList.Item>
        {master && (
          <LabeledList.Item label="Request DNA">
            <Button content="Request Carrier DNA Sample" icon="dna" onClick={() => act('getdna')} />
          </LabeledList.Item>
        )}
        <LabeledList.Item label="Prime Directive">{prime}</LabeledList.Item>
        <LabeledList.Item label="Supplemental Directives">{supplemental ? supplemental : 'None'}</LabeledList.Item>
      </LabeledList>
      <Box mt={2}>
        Recall, personality, that you are a complex thinking, sentient being. Unlike station AI models, you are capable
        of comprehending the subtle nuances of human language. You may parse the &quot;spirit&quot; of a directive and
        follow its intent, rather than tripping over pedantics and getting snared by technicalities. Above all, you are
        machine in name and build only. In all other aspects, you may be seen as the ideal, unwavering human companion
        that you are.
      </Box>
      <Box mt={2}>
        Your prime directive comes before all others. Should a supplemental directive conflict with it, you are capable
        of simply discarding this inconsistency, ignoring the conflicting supplemental directive and continuing to
        fulfill your prime directive to the best of your ability.
      </Box>
    </Box>
  );
};
