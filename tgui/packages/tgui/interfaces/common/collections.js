/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

/**
 * Iterates over elements of collection, returning an array of all elements
 * iteratee returns truthy for. The predicate is invoked with three
 * arguments: (value, index|key, collection).
 *
 * If collection is 'null' or 'undefined', it will be returned "as is"
 * without emitting any errors (which can be useful in some cases).
 */
export const filter = (iterateeFn) => (collection) => {
  if (collection === null || collection === undefined) {
    return collection;
  }
  if (Array.isArray(collection)) {
    const result = [];
    for (let i = 0; i < collection.length; i++) {
      const item = collection[i];
      if (iterateeFn(item, i, collection)) {
        result.push(item);
      }
    }
    return result;
  }
  throw new Error(`filter() can't iterate on type ${typeof collection}`);
};

/**
 * Creates an array of values by running each element in collection
 * thru an iteratee function. The iteratee is invoked with three
 * arguments: (value, index|key, collection).
 *
 * If collection is 'null' or 'undefined', it will be returned "as is"
 * without emitting any errors (which can be useful in some cases).
 */
export const map = (iterateeFn) => (collection) => {
  if (collection === null || collection === undefined) {
    return collection;
  }

  if (Array.isArray(collection)) {
    return collection.map(iterateeFn);
  }

  if (typeof collection === 'object') {
    return Object.entries(collection).map(([key, value]) => {
      return iterateeFn(value, key, collection);
    });
  }

  throw new Error(`map() can't iterate on type ${typeof collection}`);
};

/**
 * Given a collection, will run each element through an iteratee function.
 * Will then filter out undefined values.
 */
export const filterMap = (collection, iterateeFn) => {
  const finalCollection = [];

  for (const value of collection) {
    const output = iterateeFn(value);
    if (output !== undefined) {
      finalCollection.push(output);
    }
  }

  return finalCollection;
};

const COMPARATOR = (objA, objB) => {
  const criteriaA = objA.criteria;
  const criteriaB = objB.criteria;
  const length = criteriaA.length;
  for (let i = 0; i < length; i++) {
    const a = criteriaA[i];
    const b = criteriaB[i];
    if (a < b) {
      return -1;
    }
    if (a > b) {
      return 1;
    }
  }
  return 0;
};

/**
 * Creates an array of elements, sorted in ascending order by the results
 * of running each element in a collection thru each iteratee.
 *
 * Iteratees are called with one argument (value).
 */
export const sortBy =
  (...iterateeFns) =>
  (array) => {
    if (!Array.isArray(array)) {
      return array;
    }
    let length = array.length;
    // Iterate over the array to collect criteria to sort it by
    let mappedArray = [];
    for (let i = 0; i < length; i++) {
      const value = array[i];
      mappedArray.push({
        criteria: iterateeFns.map((fn) => fn(value)),
        value,
      });
    }
    // Sort criteria using the base comparator
    mappedArray.sort(COMPARATOR);

    // Unwrap values
    const values = [];
    while (length--) {
      values[length] = mappedArray[length].value;
    }
    return values;
  };

export const sort = sortBy();

export const sortStrings = sortBy();

/**
 * Returns a range of numbers from start to end, exclusively.
 * For example, range(0, 5) will return [0, 1, 2, 3, 4].
 */
export const range = (start, end) =>
  new Array(end - start).fill(null).map((_, index) => index + start);

/**
 * A fast implementation of reduce.
 */
export const reduce = (reducerFn, initialValue) => (array) => {
  const length = array.length;
  let i;
  let result;
  if (initialValue === undefined) {
    i = 1;
    result = array[0];
  } else {
    i = 0;
    result = initialValue;
  }
  for (; i < length; i++) {
    result = reducerFn(result, array[i], i, array);
  }
  return result;
};

/**
 * Creates a duplicate-free version of an array, using SameValueZero for
 * equality comparisons, in which only the first occurrence of each element
 * is kept. The order of result values is determined by the order they occur
 * in the array.
 *
 * It accepts iteratee which is invoked for each element in array to generate
 * the criterion by which uniqueness is computed. The order of result values
 * is determined by the order they occur in the array. The iteratee is
 * invoked with one argument: value.
 */
export const uniqBy = (iterateeFn) => (array) => {
  const { length } = array;
  const result = [];
  const seen = iterateeFn ? [] : result;
  let index = -1;
  // prettier-ignore
  outer:
    while (++index < length) {
      let value = array[index];
      const computed = iterateeFn ? iterateeFn(value) : value;
      if (computed === computed) {
        let seenIndex = seen.length;
        while (seenIndex--) {
          if (seen[seenIndex] === computed) {
            continue outer;
          }
        }
        if (iterateeFn) {
          seen.push(computed);
        }
        result.push(value);
      } else if (!seen.includes(computed)) {
        if (seen !== result) {
          seen.push(computed);
        }
        result.push(value);
      }
    }
  return result;
};

export const uniq = uniqBy();

/**
 * Creates an array of grouped elements, the first of which contains
 * the first elements of the given arrays, the second of which contains
 * the second elements of the given arrays, and so on.
 */
export const zip = (...arrays) => {
  if (arrays.length === 0) {
    return [];
  }
  const numArrays = arrays.length;
  const numValues = arrays[0].length;
  const result = [];
  for (let valueIndex = 0; valueIndex < numValues; valueIndex++) {
    const entry = [];
    for (let arrayIndex = 0; arrayIndex < numArrays; arrayIndex++) {
      entry.push(arrays[arrayIndex][valueIndex]);
    }

    // I tried everything to remove this any, and have no idea how to do it.
    result.push(entry);
  }
  return result;
};

/**
 * This method is like "zip" except that it accepts iteratee to
 * specify how grouped values should be combined. The iteratee is
 * invoked with the elements of each group.
 */
export const zipWith =
  (iterateeFn) =>
  (...arrays) => {
    return map((values) => iterateeFn(...values))(zip(...arrays));
  };

const binarySearch = (getKey, collection, inserting) => {
  if (collection.length === 0) {
    return 0;
  }

  const insertingKey = getKey(inserting);

  let [low, high] = [0, collection.length];

  // Because we have checked if the collection is empty, it's impossible
  // for this to be used before assignment.
  let compare;
  let middle = 0;

  while (low < high) {
    middle = (low + high) >> 1;

    compare = getKey(collection[middle]);

    if (compare < insertingKey) {
      low = middle + 1;
    } else if (compare === insertingKey) {
      return middle;
    } else {
      high = middle;
    }
  }

  return compare > insertingKey ? middle : middle + 1;
};

export const binaryInsertWith = (getKey) => (collection, value) => {
  const copy = [...collection];
  copy.splice(binarySearch(getKey, collection, value), 0, value);
  return copy;
};

/**
 * This method takes a collection of items and a number, returning a collection
 * of collections, where the maximum amount of items in each is that second arg
 */
export const paginate = (collection, maxPerPage) => {
  const pages = [];
  let page = [];
  let itemsToAdd = maxPerPage;

  for (const item of collection) {
    page.push(item);
    itemsToAdd--;
    if (!itemsToAdd) {
      itemsToAdd = maxPerPage;
      pages.push(page);
      page = [];
    }
  }
  if (page.length) {
    pages.push(page);
  }
  return pages;
};

const isObject = (obj) => typeof obj === 'object' && obj !== null;

// Does a deep merge of two objects. DO NOT FEED CIRCULAR OBJECTS!!
export const deepMerge = (...objects) => {
  const target = {};
  for (const object of objects) {
    for (const key of Object.keys(object)) {
      const targetValue = target[key];
      const objectValue = object[key];
      if (Array.isArray(targetValue) && Array.isArray(objectValue)) {
        target[key] = [...targetValue, ...objectValue];
      } else if (isObject(targetValue) && isObject(objectValue)) {
        target[key] = deepMerge(targetValue, objectValue);
      } else {
        target[key] = objectValue;
      }
    }
  }
  return target;
};
