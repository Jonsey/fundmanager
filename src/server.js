let express = require('express');
let bodyParser = require('body-parser');
const app = express();
let expressWS = require('express-ws')(app);

import handleUserData from './server/user-data';

import { Config, CognitoIdentityCredentials } from 'aws-sdk';
import {
    CognitoUserPool,
    AuthenticationDetails,
    CognitoUserAttribute,
    CognitoUser,
} from 'amazon-cognito-identity-js';

const router = express.Router();

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

app.use(function(req, res, next) {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
    next();
});

let binance = require('binance-api-node').default;

const client = binance();

const client2 = binance({
    apiKey: 'secret',
    apiSecret: 'secret',
});

const portNumber = 3000;

app.listen(portNumber, () => {
    console.log(`Listening on port ${portNumber}`);
});

app.post('/users', (req, res) => {
    const userPool = new CognitoUserPool({
        UserPoolId: 'us-east-df',
        ClientId: 'secret',
    });

    const email = req.body.user.email.trim();
    const password = req.body.user.password.trim();
    const attributeList = [
        new CognitoUserAttribute({
            Name: 'email',
            Value: email,
        }),
    ];
    userPool.signUp(email, password, attributeList, null, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }
        console.log('user name is ' + result.user.getUsername());
        console.log('call result: ' + result);
    });
});

app.get('/users/logout', (req, res) => {});

app.post('/users/login', (req, res) => {
    const email = req.body.user.email.trim();
    const password = req.body.user.password.trim();

    let authenticationData = {
        Username: email,
        Password: password,
    };

    let authenticationDetails = new AuthenticationDetails(authenticationData);

    const userPool = new CognitoUserPool({
        UserPoolId: 'us-east-',
        ClientId: 'secret',
    });

    let userData = {
        Username: email,
        Pool: userPool,
    };

    let cognitoUser = new CognitoUser(userData);
    cognitoUser.authenticateUser(authenticationDetails, {
        onSuccess: function(result) {
            console.log('access token + ' + result.getAccessToken().getJwtToken());

            const user = {
                email: email,
                token: result.getAccessToken().getJwtToken(),
                username: email,
            };

            res.send({ user: user });

        },

        onFailure: function(err) {
            console.error('Failure', err);
        },
    });
});

app.get('/binance/exchange-info', async (req, res) => {
    try {
        const response = await client.exchangeInfo();

        console.log('Exchange Resp:', response.symbols[0].filters[1]);

        const symbols = response.symbols;

        let data = [];

        symbols.map(symbol => {
            if (symbol.status === 'TRADING') {
                const priceFilter = symbol.filters.find(
                    filter => filter.filterType === 'PRICE_FILTER'
                );
                const lotSize = symbol.filters.find(filter => filter.filterType === 'LOT_SIZE');

                data.push({
                    pairId: symbol.symbol,
                    precision: parseFloat(symbol.quotePrecision),
                    tickSize: parseFloat(priceFilter.tickSize),
                    minQuantity: parseFloat(lotSize.minQty),
                    stepSize: parseFloat(lotSize.stepSize),
                });
            }
        });

        res.send(data);
    } catch (e) {
        res.status(500).send({ error: `Error fetching exchange info ${e.message}` });
    }
});

app.get('/binance/account-info', async (req, res) => {
    console.log('Hit /binance/account-info');

    try {
        const response = await client2.accountInfo();
        console.log(response);

        let balances = [];

        response.balances.map(x => {
            if (x.free > 0) {
                balances.push({
                    asset: x.asset,
                    free: parseFloat(x.free),
                    locked: parseFloat(x.locked),
                });
            }
        });

        const data = {
            balances: balances,
        };
        res.send(data);
    } catch (e) {
        res.status(500).send({ error: `Error fetching account info ${e.message}` });
    }
});

app.get('/binance/chart/:pairId/:interval/:limit', function(req, res) {
    try {
        client
            .candles({
                symbol: req.params.pairId,
                interval: req.params.interval,
                limit: req.params.limit,
            })
            .then(candles => {
                const data = {
                    pairId: req.params.pairId,
                    interval: req.params.interval,
                    data: candles,
                };

                res.send(data);
            });
    } catch (e) {
        res.status(500).send({
            error: `Error fetching chart data for ${req.params.pairId} ${e.message}`,
        });
    }
});

app.get('/binance/my-trades/:pairId/:limit/:fromId', async (req, res) => {
    try {
        const params = req.params;

        const response = await client2.myTrades({
            symbol: params.pairId,
            limit: params.limit,
            fromId: params.fromId,
        });

        res.send(response);
    } catch (e) {
        res.status(500).send({
            error: `Error fetching my trades ${req.params.pairId} ${e.message}`,
        });
    }
});

app.get('/binance/order', async (req, res) => {
    const params = req.query;

    console.log('Order Request: ', params);

    try {
        const response = await client2.order({
            symbol: params.pairId,
            side: 'BUY',
            type: 'LIMIT',
            quantity: params.amount,
            price: params.price,
        });

        console.log('Order response: ', response);

        if (response.status === 'FILLED') {
            res.status(200).send();
        } else {
            res.status(500).send('Order failed');
        }
    } catch (e) {
        console.log('Order response: ', e);
        res.status(500).send('Order failed');
    }
});

app.post('/binance/order/market', async (req, res) => {
    console.log('Market Order Placing', req.body);
    const { pairId, quantity } = req.body;

    try {
        const response = await client2.order({
            symbol: pairId,
            side: 'BUY',
            type: 'MARKET',
            quantity,
        });

        console.log('Market Order response: ', response);

        if (response.status === 'FILLED') {
            res.status(200).send(response);
        } else {
            res.status(500).send('Market Order failed');
        }
    } catch (e) {
        console.log('Order response: ', e);
        res.status(500).send('Market Order failed');
    }
});

app.post('/binance/order/close/market', async (req, res) => {
    const params = req.body;

    console.log('Close Trade(market) Request: ', params);

    try {
        const response = await client2.order({
            symbol: params.pairId,
            side: 'SELL',
            type: 'MARKET',
            quantity: params.quantity,
        });

        console.log('Order response: ', response);

        res.status(200).send();
    } catch (e) {
        console.log('Close Trade(market) Failed response: ', e);
        res.status(500).send('Order failed');
    }
});

app.get('/binance/stop', async (req, res) => {
    const params = req.query;

    console.log('Order Request: ', params);

    // const response = await client2.order({
    //     symbol: params.pairId,
    //     side: 'SELL',
    //     type: 'LIMIT',
    //     quantity: params.amount,
    //     price: params.price
    // })

    const response = await client2.order({
        symbol: params.pairId,
        side: 'SELL',
        type: 'MARKET',
        quantity: params.amount,
    });

    console.log('Stop Order response: ', response);

    res.send(response);
});

app.get('/binance/limit', async (req, res) => {
    const params = req.query;

    console.log('Order Request: ', params);

    const response = await client2.order({
        symbol: params.pairId,
        side: 'SELL',
        type: 'LIMIT',
        quantity: params.amount,
        price: params.price,
    });

    console.log('Stop Order response: ', response);

    res.send(response);
});

app.get('/binance/order/close', async (req, res) => {
    const params = req.query;

    console.log('Close Order Request: ', params);

    const response = await client2.cancelOrder({
        symbol: params.pairId,
        orderId: params.orderId,
    });

    console.log('Close Order response: ', response);

    res.send(response);
});

let candleClean = [];
let tickerClean = [];

expressWS.getWss().on('connection', function(ws) {
    console.log('connection open');
    // candleClean = [];
    // tickerClean = [];
});

app.ws('/binance/account-info', async (socket, req) => {
    try {
        console.log('Account info connected.');

        const interval = setInterval(function timeout() {
            console.log('Pining', socket.readyState);
            socket.ping('heartbeat');
        }, 5000);

        const clean = await client2.ws.user(msg => {
            handleUserData(msg, socket);
        });

        socket.on('close', ws => {
            console.log('Socket closing ');
            clearInterval(interval);
            // clean(1000);
            // closeExchangeSockets('', [candleClean, tickerClean]);
        });
    } catch (e) {
        console.log('Error in binance account info socket: ', e);
    }
});

app.ws('/binance/ticker/:pairId', async (socket, req) => {
    const pairId = req.params.pairId;

    console.log('/binance/ticker/:pairId');

    if (tickerClean.some(x => x.pairId === pairId)) {
        return;
    }

    socket.on('close', function(ws) {
        console.log('Socket closing');
        closeExchangeSockets(pairId, [candleClean, tickerClean]);
    });

    const clean = await client.ws.ticker(req.params.pairId, ticker => {
        try {
            socket.send(JSON.stringify(ticker));
        } catch (e) {
            console.log('Error sending ticker.', e);
        }
    });

    tickerClean.push({ pairId: req.params.pairId, cleanFunction: clean });
    console.log('Open ticker connections: ', tickerClean.length);
});

app.ws('/binance/:pairId/:interval', async (socket, req) => {
    const pairId = req.params.pairId;

    console.log('/binance/:pairId/:interval');

    socket.on('close', function(ws) {
        console.log('Socket closing');
        closeExchangeSockets(pairId, [candleClean, tickerClean]);
    });

    closeAllCandleSockets(candleClean);

    const clean = await client.ws.candles(pairId, req.params.interval, candle => {
        try {
            socket.send(JSON.stringify(candle));
        } catch (e) {
            console.log('Error sending candle.');
        }
    });

    candleClean.push({ pairId: pairId, cleanFunction: clean });
});

const closeAllCandleSockets = candleClean => {
    candleClean.map(c => c.cleanFunction());
    candleClean = [];
};

const closeExchangeSockets = (pairId, cleaners) => {
    cleaners.map(cleaner => {
        cleaner.map(x => x.cleanFunction());
        cleaner = cleaner.filter(x => x.pairId !== pairId);
    });
};
