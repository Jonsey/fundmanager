export const lastResistance = (current, high) => {
  // const current = getCurrent(high);
  const data = high.reverse();

  for (var i = 1; i < data.length; i++) {
    if (data[i] >= current) {
      return data[i];
    }

    return null;
  }
}

export const lastSupport = (current, high) => {
  // const current = getCurrent(low);

  for (var i = 1; i < high.length; i++) {
    if (high[i] <= current) {
      return high[i];
    }

    return null;
  }
}

const getCurrent = (values) => {
  return values.splice(-1)
}
