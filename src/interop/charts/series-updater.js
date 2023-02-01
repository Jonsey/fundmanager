import bollingerBands from '../analysis/bollinger-bands';

export const ohlcUpdater = (series, message) => {

    const candle = JSON.parse(message.data);

    const point = {
        x: parseInt(candle.startTime),
        open: parseFloat(candle.open),
        high: parseFloat(candle.high),
        low: parseFloat(candle.low),
        close: parseFloat(candle.close)
    };

    updatePoint(series, candle, point);
}

export const volUpdater = (series, message) => {
    const candle = JSON.parse(message.data);

    const point = {
        x: parseInt(candle.startTime),
        y: parseInt(candle.volume) // the volume
    };

    updatePoint(series, candle, point);
}

export const  bbUpdater = (seriesUpper, seriesMiddle, seriesLower, close, message) => {
    const candle = JSON.parse(message.data);

    close.push(parseFloat(candle.close));

    const [smaData, bbUpperData, bbLowerData] = bollingerBands(close, 20);

    const i = seriesUpper.xData.length - 1;

    updateBB(i, seriesUpper, candle, bbUpperData)
    updateBB(i, seriesMiddle, candle, smaData)
    updateBB(i, seriesLower, candle, bbLowerData)
}

const updateBB = (index, series, candle, bbData) => {
    const value = bbData[index];

    const point = {
        x: parseInt(candle.startTime),
        y: value
    };

    updatePoint(series, candle, point);
}

const updatePoint = (series, candle, point) => {
    const i = series.xData.length - 1
    let currentPoint = series.xData[i];

    if (currentPoint === candle.startTime) {
        series.removePoint(i, false, false);
        series.addPoint(point, false, false, false);
    } else {
        series.addPoint(point, false, true, false);
    }
}
