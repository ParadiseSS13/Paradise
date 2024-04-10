import { useBackend } from '../../backend';

export const RndRoute = (properties, context) => {
  const { render } = properties;
  const { data } = useBackend(context);
  const { menu, submenu } = data;

  const compare = (comparator, item) => {
    if (comparator === null || comparator === undefined) {
      return true;
    } // unspecified, match all
    if (typeof comparator === 'function') {
      return comparator(item);
    }
    return comparator === item; // strings or ints?
  };

  let match = compare(properties.menu, menu) && compare(properties.submenu, submenu);

  if (!match) {
    return null;
  }

  return render();
};
