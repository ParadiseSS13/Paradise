import { Component, createRef } from 'inferno';

interface Props {
  children: any;
}

/**
 * A vertical list that renders items to fill space up to the extents of the
 * current window, and then defers rendering of other items until they come
 * into view.
 */
export class VirtualList extends Component<Props, any> {
  containerRef: any;
  intervalId: any;

  constructor(props: Props) {
    super(props);

    this.containerRef = createRef();
    this.state = {
      visibleElements: 1,
      padding: 0,
    };
  }

  adjustExtents = () => {
    const { children } = this.props;
    const { visibleElements } = this.state;
    const current = this.containerRef.current;

    if (!children || !Array.isArray(children) || !current || visibleElements >= children.length) {
      return;
    }

    const unusedArea = document.body.offsetHeight - current.getBoundingClientRect().bottom;
    const averageItemHeight = Math.ceil(current.offsetHeight / visibleElements);

    if (unusedArea > 0) {
      const newVisibleElements = Math.min(
        children.length,
        visibleElements + Math.max(1, Math.ceil(unusedArea / averageItemHeight))
      );

      this.setState({
        visibleElements: newVisibleElements,
        padding: (children.length - newVisibleElements) * averageItemHeight,
      });
    }
  };

  componentDidMount() {
    this.adjustExtents();
    this.intervalId = setInterval(this.adjustExtents, 100);
  }

  componentWillUnmount() {
    clearInterval(this.intervalId);
  }

  render() {
    const { children } = this.props;
    const { visibleElements, padding } = this.state;

    return (
      <div className={'VirtualList'}>
        <div className={'VirtualList__Container'} ref={this.containerRef}>
          {Array.isArray(children) ? children.slice(0, visibleElements) : null}
        </div>
        <div className={'VirtualList__Padding'} style={{ 'padding-bottom': `${padding}px` }} />
      </div>
    );
  }
}
