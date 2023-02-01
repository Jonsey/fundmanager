require('./styles/main.scss');

// import {iconToggle} from 'material-components-web';

import { drawChart } from '../interop/chart';
import createAnalysisWebSocket from '../interop/analysis_api';

// inject bundled Elm app into div#main
let Elm = require('../elm/Main');
const elmApp = Elm.Main.embed(document.getElementById('main'));

// iconToggle.attachTo(document.querySelector('.mdc-icon-toggle'));
// const iconToggle = new iconToggle.MDCIconToggle(document.querySelector('.mdc-icon-toggle'));

createAnalysisWebSocket(elmApp);

elmApp.ports.storeSession.subscribe(function(session) {
    localStorage.session = session;
});

window.addEventListener(
    'storage',
    function(event) {
        if (event.storageArea === localStorage && event.key === 'session') {
            elmApp.ports.onSessionChange.send(event.newValue);
        }
    },
    false
);

// receive something from Elm
elmApp.ports.drawChart.subscribe(function(data) {
    const response = JSON.parse(data);
    if (response.error) {
        console.log('Error fetching chart data: ', response.error);
    } else {
        drawChart(JSON.parse(data));
    }
});

elmApp.ports.requestAccountInfo.subscribe(() => {
    const wsUri = 'ws://localhost:3000/binance/account-info';
    const connection = new WebSocket(wsUri);

    connection.onmessage = message => {
        try {
            console.log('Account info client side:', message);

            const data = JSON.parse(message.data);

            if (data.eventType === 'ORDER') {
                elmApp.ports.orderReceived.send(data);
            }

            if (data.eventType === 'TRADE') {
                elmApp.ports.tradeReceived.send(data);
            }

            if (data.eventType === 'ACCOUNT') {
                console.log('Account info message before sending to port: ', data);
                elmApp.ports.accountInfoRecieved.send(data);
            }
        } catch (e) {
            console.log('Error recieving account info message', e.message);
        }
    };
});

let connections = {};

elmApp.ports.requestTicker.subscribe(function(pairId) {
    console.log('Requested ticker');

    var wsUri = `ws://localhost:3000/binance/ticker/${pairId}`;

    if (connections[wsUri]) {
        return;
    }

    var connection = new WebSocket(wsUri);

    connection.onmessage = message => {
        const binanceTicker = JSON.parse(message.data);

        const ticker = {
            id: binanceTicker.symbol,
            name: binanceTicker.symbol,
            last: parseFloat(binanceTicker.curDayClose),
            lowestAsk: parseFloat(binanceTicker.bestAsk),
            highestBid: parseFloat(binanceTicker.bestBid),
            percentChange: parseFloat(binanceTicker.priceChangePercent),
            baseVolume: parseFloat(binanceTicker.volume),
            quoteVolume: parseFloat(binanceTicker.volumeQuote),
            isFrozen: false,
            dayHigh: parseFloat(binanceTicker.high),
            dayLow: parseFloat(binanceTicker.low),
        };

        elmApp.ports.tickerReceived.send(ticker);
    };

    connections[wsUri] = connection;
});
