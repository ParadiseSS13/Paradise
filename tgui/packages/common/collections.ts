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
export const filter = <T>(collection: T[], iterateeFn: (input: T, index: number, collection: T[]) => boolean): T[] => {
  if (collection === null || collection === undefined) {
    return collection;
  }
  if (Array.isArray(collection)) {
    const result: T[] = [];
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

type MapFunction = {
  <T, U>(collection: T[], iterateeFn: (value: T, index: number, collection: T[]) => U): U[];

  <T, U, K extends string | number>(
    collection: Record<K, T>,
    iterateeFn: (value: T, index: K, collection: Record<K, T>) => U
  ): U[];
};

/**
 * Creates an array of values by running each element in collection
 * thru an iteratee function. The iteratee is invoked with three
 * arguments: (value, index|key, collection).
 *
 * If collection is 'null' or 'undefined', it will be returned "as is"
 * without emitting any errors (which can be useful in some cases).
 */
export const map: MapFunction = (collection, iterateeFn) => {
  if (collection === null || collection === undefined) {
    return collection;
  }

  if (Array.isArray(collection)) {
    const result: unknown[] = [];
    for (let i = 0; i < collection.length; i++) {
      result.push(iterateeFn(collection[i], i, collection));
    }
    return result;
  }

  if (typeof collection === 'object') {
    const result: unknown[] = [];
    for (let i in collection) {
      if (Object.prototype.hasOwnProperty.call(collection, i)) {
        result.push(iterateeFn(collection[i], i, collection));
      }
    }
    return result;
  }

  throw new Error(`map() can't iterate on type ${typeof collection}`);
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
export const sortBy = <T>(array: T[], ...iterateeFns: ((input: T) => unknown)[]): T[] => {
  if (!Array.isArray(array)) {
    return array;
  }
  let length = array.length;
  // Iterate over the array to collect criteria to sort it by
  let mappedArray: {
    criteria: unknown[];
    value: T;
  }[] = [];
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
  const values: T[] = [];
  while (length--) {
    values[length] = mappedArray[length].value;
  }
  return values;
};

export const sort = <T>(array: T[]): T[] => sortBy(array);

/**
 * Returns a range of numbers from start to end, exclusively.
 * For example, range(0, 5) will return [0, 1, 2, 3, 4].
 */
export const range = (start: number, end: number): number[] =>
  new Array(end - start).fill(null).map((_, index) => index + start);

type ReduceFunction = {
  <T, U>(
    array: T[],
    reducerFn: (accumulator: U, currentValue: T, currentIndex: number, array: T[]) => U,
    initialValue: U
  ): U;
  <T>(array: T[], reducerFn: (accumulator: T, currentValue: T, currentIndex: number, array: T[]) => T): T;
};

/**
 * A fast implementation of reduce.
 */
export const reduce: ReduceFunction = (array, reducerFn, initialValue?) => {
  const length = array.length;
  let i: number;
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
export const uniqBy = <T extends unknown>(array: T[], iterateeFn?: (value: T) => unknown): T[] => {
  const { length } = array;
  const result: T[] = [];
  const seen: unknown[] = iterateeFn ? [] : result;
  let index = -1;
  // prettier-ignore
  outer:
    while (++index < length) {
      let value: T | 0 = array[index];
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

export const uniq = <T>(array: T[]): T[] => uniqBy(array);

type Zip<T extends unknown[][]> = {
  [I in keyof T]: T[I] extends (infer U)[] ? U : never;
}[];

/**
 * Creates an array of grouped elements, the first of which contains
 * the first elements of the given arrays, the second of which contains
 * the second elements of the given arrays, and so on.
 */
export const zip = <T extends unknown[][]>(...arrays: T): Zip<T> => {
  if (arrays.length === 0) {
    return [];
  }
  const numArrays = arrays.length;
  const numValues = arrays[0].length;
  const result: Zip<T> = [];
  for (let valueIndex = 0; valueIndex < numValues; valueIndex++) {
    const entry: unknown[] = [];
    for (let arrayIndex = 0; arrayIndex < numArrays; arrayIndex++) {
      entry.push(arrays[arrayIndex][valueIndex]);
    }

    // I tried everything to remove this any, and have no idea how to do it.
    result.push(entry as any);
  }
  return result;
};

const binarySearch = <T, U = unknown>(getKey: (value: T) => U, collection: readonly T[], inserting: T): number => {
  if (collection.length === 0) {
    return 0;
  }

  const insertingKey = getKey(inserting);

  let [low, high] = [0, collection.length];

  // Because we have checked if the collection is empty, it's impossible
  // for this to be used before assignment.
  let compare: U = undefined as unknown as U;
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

export const binaryInsertWith = <T, U = unknown>(collection: readonly T[], value: T, getKey: (value: T) => U): T[] => {
  const copy = [...collection];
  copy.splice(binarySearch(getKey, collection, value), 0, value);
  return copy;
};

/**
 * This method takes a collection of items and a number, returning a collection
 * of collections, where the maximum amount of items in each is that second arg
 */
export const paginate = <T>(collection: T[], maxPerPage: number): T[][] => {
  const pages: T[][] = [];
  let page: T[] = [];
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

const isObject = (obj: unknown): obj is object => typeof obj === 'object' && obj !== null;

// Does a deep merge of two objects. DO NOT FEED CIRCULAR OBJECTS!!
export const deepMerge = (...objects: any[]): any => {
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
