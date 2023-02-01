import Highcharts from 'highcharts/highstock';
import bollingerBands from './analysis/bollinger-bands';
import { ohlcUpdater, volUpdater, bbUpdater } from './charts/series-updater';

let connections = [];

export function drawChart({ pairId, interval, data }) {
    var ohlc = [],
        volume = [],
        sma = [],
        smaData = [],
        bbUpper = [],
        bbUpperData = [],
        bbLower = [],
        bbLowerData = [],
        dataLength = data.length,
        // set the allowed units for data grouping
        groupingUnits = [
            ['minute', [1, 5, 15, 30, 60, 120]],
            ['week', [1]],
            ['month', [1, 2, 3, 4, 6]],
        ],
        i = 0;

    let close = data.map(x => parseFloat(x.close));
    [smaData, bbUpperData, bbLowerData] = bollingerBands(close, 20);

    for (i; i < dataLength; i += 1) {
        ohlc.push([
            parseInt(data[i].openTime), // the date
            parseFloat(data[i].open), // open
            parseFloat(data[i].high), // high
            parseFloat(data[i].low), // low
            parseFloat(data[i].close), // close
        ]);

        volume.push([
            parseInt(data[i].openTime), // the date
            parseInt(data[i].volume), // the volume
        ]);

        sma.push([
            parseInt(data[i].openTime), // the date
            smaData[i], // the volume
        ]);

        bbUpper.push([
            parseInt(data[i].openTime), // the date
            bbUpperData[i], // the volume
        ]);

        bbLower.push([
            parseInt(data[i].openTime), // the date
            bbLowerData[i], // the volume
        ]);
    }

    let currentClose = close[dataLength - 1];
    let resistance = currentClose * 1.01;
    let support = currentClose - currentClose * 0.01;

    // create the chart

    Highcharts.stockChart(`chart-${interval}`, {
        chart: {
            height: 600,
            events: {
                load: function() {
                    var self = this;
                    if (interval === '1m') {
                        console.log('CHart loaded', connections);
                        var wsUri = `ws://localhost:3000/binance/${pairId}/${interval}`;

                        if (connections[wsUri] === undefined || connections[wsUri] === null) {
                            console.log('Creating new connection');
                            var connection = new WebSocket(wsUri);

                            connection.onmessage = message => {
                                if (self.series) {
                                    const CLOSE = 3;
                                    let closeData = self.series[0].yData.map(x => x[CLOSE]);
                                    ohlcUpdater(self.series[0], message);
                                    volUpdater(self.series[1], message);
                                    bbUpdater(
                                        self.series[3],
                                        self.series[2],
                                        self.series[4],
                                        closeData,
                                        message
                                    );

                                    self.redraw();
                                }
                            };

                            connections[wsUri] = connection;
                        } else {
                            connections[wsUri].onmessage = message => {
                                if (self.series) {
                                    const CLOSE = 3;
                                    let closeData = self.series[0].yData.map(x => x[CLOSE]);
                                    ohlcUpdater(self.series[0], message);
                                    volUpdater(self.series[1], message);
                                    bbUpdater(
                                        self.series[3],
                                        self.series[2],
                                        self.series[4],
                                        closeData,
                                        message
                                    );

                                    self.redraw();
                                }
                            };
                        }
                    }
                },
            },
        },

        units: groupingUnits,

        rangeSelector: {
            selected: 1,
        },

        title: {
            text: `${pairId} - ${interval}`,
        },

        yAxis: [
            {
                labels: {
                    align: 'right',
                    x: -3,
                },

                title: {
                    text: 'OHLC',
                },

                height: '70%',

                lineWidth: 2,

                resize: {
                    enabled: true,
                },

                plotLines: [
                    {
                        value: resistance,
                        color: 'green',
                        dashStyle: 'shortdash',
                        width: 1,
                        label: {
                            text: '1% Profit',
                        },
                    },
                    {
                        value: support,
                        color: 'red',
                        dashStyle: 'shortdash',
                        width: 1,
                        label: {
                            text: '1% Loss',
                        },
                    },
                ],
            },
            {
                labels: {
                    align: 'right',
                    x: -3,
                },
                title: {
                    text: 'Volume',
                },
                top: '65%',
                height: '35%',
                offset: 0,
                lineWidth: 2,
            },
        ],

        tooltip: {
            split: true,
        },

        series: [
            {
                type: 'candlestick',
                name: `${pairId}`,
                data: ohlc,
                pointInterval: 60 * 1000,
                dataGrouping: {
                    units: groupingUnits,
                },
            },
            {
                type: 'column',
                name: 'Volume',
                data: volume,
                yAxis: 1,
                dataGrouping: {
                    units: groupingUnits,
                },
            },
            {
                type: 'line',
                name: 'SMA',
                data: sma,
                linkedTo: `${pairId}`,
                dataGrouping: {
                    units: groupingUnits,
                },
            },
            {
                type: 'line',
                name: 'bbUpper',
                data: bbUpper,
                linkedTo: `${pairId}`,
                dataGrouping: {
                    units: groupingUnits,
                },
            },
            {
                type: 'line',
                name: 'bbLower',
                data: bbLower,
                linkedTo: `${pairId}`,
                dataGrouping: {
                    units: groupingUnits,
                },
            },
        ],
    });
}
