import { Dimmer, Flex, Icon } from 'tgui-core/components';

type OperatingTypes = {
  /**
   * Is the machine currently operating
   */
  operating: boolean;
  /**
   * The name of the machine
   */
  name: string;
};

/**
 * Shows a spinner while a machine is processing
 * @property {object} props
 */
export const Operating = (props: OperatingTypes) => {
  const { operating, name } = props;
  if (operating) {
    return (
      <Dimmer>
        <Flex mb="30px">
          <Flex.Item bold color="silver" textAlign="center">
            <Icon name="spinner" spin size={4} mb="15px" />
            <br />
            The {name} is processing...
          </Flex.Item>
        </Flex>
      </Dimmer>
    );
  }
};
