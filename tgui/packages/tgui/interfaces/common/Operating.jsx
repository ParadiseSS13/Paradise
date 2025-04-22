import { Flex, Icon, Dimmer } from '../../components';
const PropTypes = require('prop-types');

/**
 * Shows a spinner while a machine is processing
 * @property {object} props
 */
export const Operating = (props) => {
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

Operating.propTypes = {
  /**
   * Is the machine currently operating
   */
  operating: PropTypes.bool,
  /**
   * The name of the machine
   */
  name: PropTypes.string,
};
