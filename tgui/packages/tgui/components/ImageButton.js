/**
 * @file
 * @copyright 2024 Aylong (https://github.com/AyIong)
 * @license MIT
 */

import { resolveAsset } from '../assets';
import { classes, pureComponentHooks } from 'common/react';
import { computeBoxClassName, computeBoxProps } from './Box';
import { Icon } from './Icon';
import { Tooltip } from './Tooltip';

export const ImageButton = (props) => {
  const {
    className,
    asset,
    color,
    title,
    vertical,
    content,
    selected,
    disabled,
    disabledContent,
    image,
    imageUrl,
    imageAsset,
    imageSize,
    tooltip,
    tooltipPosition,
    ellipsis,
    children,
    onClick,
    ...rest
  } = props;
  rest.onClick = (e) => {
    if (!disabled && onClick) {
      onClick(e);
    }
  };
  let buttonContent = (
    <div
      className={classes([
        vertical ? 'ImageButton__vertical' : 'ImageButton__horizontal',
        selected && 'ImageButton--selected',
        disabled && 'ImageButton--disabled',
        color && typeof color === 'string'
          ? onClick
            ? 'ImageButton--color--clickable--' + color
            : 'ImageButton--color--' + color
          : onClick
            ? 'ImageButton--color--default--clickable'
            : 'ImageButton--color--default',
        className,
        computeBoxClassName(rest),
      ])}
      tabIndex={!disabled && '0'}
      {...computeBoxProps(rest)}
    >
      <div className={classes(['ImageButton__image'])}>
        {asset ? (
          <div className={classes([imageAsset, image])} />
        ) : (
          <img
            src={
              imageUrl
                ? resolveAsset(imageUrl)
                : `data:image/jpeg;base64,${image}`
            }
            style={{
              width: imageSize,
              height: imageSize,
              '-ms-interpolation-mode': 'nearest-neighbor', // Remove after 516 release
              'image-rendering': 'pixelated',
            }}
          />
        )}
      </div>
      {content &&
        (vertical ? (
          <div
            className={classes([
              'ImageButton__content__vertical',
              ellipsis && 'ImageButton__content--ellipsis',
              selected && 'ImageButton__content--selected',
              disabled && 'ImageButton__content--disabled',
              color && typeof color === 'string'
                ? 'ImageButton__content--color--' + color
                : 'ImageButton__content--color--default',
              className,
              computeBoxClassName(rest),
            ])}
          >
            {disabled && disabledContent ? disabledContent : content}
          </div>
        ) : (
          <div className={classes(['ImageButton__content__horizontal'])}>
            {title && (
              <div
                className={classes(['ImageButton__content__horizontal--title'])}
              >
                {title}
                <div
                  className={classes([
                    'ImageButton__content__horizontal--divider',
                  ])}
                />
              </div>
            )}
            <div
              className={classes(['ImageButton__content__horizontal--content'])}
            >
              {content}
            </div>
          </div>
        ))}
    </div>
  );

  if (tooltip) {
    buttonContent = (
      <Tooltip content={tooltip} position={tooltipPosition}>
        {buttonContent}
      </Tooltip>
    );
  }

  return (
    <div
      className={classes([
        vertical ? 'ImageButton--vertical' : 'ImageButton--horizontal',
      ])}
    >
      {buttonContent}
      {children}
    </div>
  );
};

ImageButton.defaultHooks = pureComponentHooks;

/**
 * That's VERY fucking expensive thing!
 * Use it only in places, where it really needed.
 * Otherwise, the window opening time may increase by a third!
 * Most of the blame is on Icon.
 * Maybe it's also because I'm a bit crooked.
 * (с) Aylong
 */
export const ImageButtonItem = (props) => {
  const {
    className,
    color,
    content,
    horizontal,
    selected,
    disabled,
    disabledContent,
    tooltip,
    tooltipPosition,
    icon,
    iconColor,
    iconPosition,
    iconRotation,
    iconSize,
    onClick,
    children,
    ...rest
  } = props;
  rest.onClick = (e) => {
    if (!disabled && onClick) {
      onClick(e);
    }
  };
  let itemContent = (
    <div>
      <div
        className={classes([
          'ImageButton__item',
          selected && 'ImageButton__item--selected',
          disabled && 'ImageButton__item--disabled',
          color && typeof color === 'string'
            ? 'ImageButton__item--color--' + color
            : 'ImageButton__item--color--default',
          className,
          computeBoxClassName(rest),
        ])}
        tabIndex={!disabled && '0'}
        {...computeBoxProps(rest)}
      >
        <div
          className={classes([
            horizontal && 'ImageButton__item--icon--horizontal',
            computeBoxClassName(rest),
            className,
          ])}
        >
          {icon && (iconPosition === 'top' || iconPosition === 'left') && (
            <Icon
              mb={0.5}
              name={icon}
              color={iconColor}
              rotation={iconRotation}
              size={iconSize}
            />
          )}
          <div>
            {disabled && disabledContent ? disabledContent : content}
            {children}
          </div>
          {icon && !(iconPosition === 'top' || iconPosition === 'left') && (
            <Icon
              mt={0.5}
              name={icon}
              color={iconColor}
              rotation={iconRotation}
              size={iconSize}
            />
          )}
        </div>
      </div>
    </div>
  );
  if (tooltip) {
    itemContent = (
      <Tooltip content={tooltip} position={tooltipPosition}>
        {itemContent}
      </Tooltip>
    );
  }

  return itemContent;
};

ImageButton.Item = ImageButtonItem;
