const standardDeviation = (values, sma) => {
    const squareDiffs = values.map(function(value){
        const diff = value - sma;
        const sqrDiff = diff * diff;
        return sqrDiff;
    });

    const avgSquareDiff = average(squareDiffs);

    const stdDev = Math.sqrt(avgSquareDiff);
    return stdDev;
}

const average = (data) => {
    const sum = data.reduce(function(sum, value){
        return sum + value;
    }, 0);

    const avg = sum / data.length;
    return avg;
}

export default standardDeviation;
