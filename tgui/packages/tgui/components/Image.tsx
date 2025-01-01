import { Component } from 'inferno';
import { BoxProps, computeBoxProps } from './Box';

type Props = Partial<{
  /** True is default, this fixes an ie thing */
  fixBlur: boolean;
  /** False by default. Good if you're fetching images on UIs that do not auto update. This will attempt to fix the 'x' icon 5 times. */
  fixErrors: boolean;
  /** Fill is default. */
  objectFit: 'contain' | 'cover';
}> &
  IconUnion &
  BoxProps;

// at least one of these is required
type IconUnion =
  | {
      className?: string;
      src: string;
    }
  | {
      className: string;
      src?: string;
    };

const maxAttempts = 5;

/** Image component. Use this instead of Box as="img". */
export class Image extends Component<Props> {
  attempts: number = 0;

  handleError = (event) => {
    const { fixErrors, src } = this.props;
    if (fixErrors && this.attempts < maxAttempts) {
      const imgElement = event.currentTarget;

      setTimeout(() => {
        imgElement.src = `${src}?attempt=${this.attempts}`;
        this.attempts++;
      }, 1000);
    }
  };

  render() {
    const { fixBlur = true, fixErrors = false, objectFit = 'fill', src, ...rest } = this.props;

    /* Remove -ms-interpolation-mode with Byond 516 */
    const computedProps = computeBoxProps({
      style: {
        '-ms-interpolation-mode': `${fixBlur ? 'nearest-neighbor' : 'auto'}`,
        'image-rendering': `${fixBlur ? 'pixelated' : 'auto'}`,
        'object-fit': `${objectFit}`,
      },
      ...rest,
    });

    /* Use div instead img if used asset, cause img with class leaves white border on 516 */
    if (computedProps.className) {
      return <div onError={this.handleError} {...computedProps} />;
    }

    return <img onError={this.handleError} src={src} {...computedProps} />;
  }
}
