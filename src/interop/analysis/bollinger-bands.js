import standardDeviation from './std-dev';

const bollingerBands = (data, period) => {
    let middle = [],
        upper = [],
        lower = [];

    for (var x = 1; x < data.length + 1; x++) {
        if(x > period) {
            var [a, b, c] = smaCalc(data.slice(0, x), period);
            middle.push(a);
            upper.push(b);
            lower.push(c);
        } else {
            middle.push(null);
            upper.push(null);
            lower.push(null);
        }
    }

    return [
        middle,
        upper,
        lower
    ]
}

const getSum = (total, num) => {
    return total + parseFloat(num);
}

const smaCalc = (close, period) => {
    const sum = close.slice(-period).reduce(getSum, 0);
    const sma = sum / period;
    const upper = sma + (standardDeviation(close.slice(-period), sma) * 2);
    const lower = sma - (standardDeviation(close.slice(-period), sma) * 2);
    return [sma, upper, lower];
}

export default bollingerBands;
