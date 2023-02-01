export const subscribeToCandles = (elmApp) => {
    const wsUri = 'ws://localhost:1234/binance';
    const connection = new WebSocket(wsUri);

    connection.onopen = function (session) {
        console.log('Binance Websocket connection opened');
    };

    connection.onmessage = (message) => {
        console.log(message.data);
    };
};

export const subscribeToAccountInfo = (elmApp) => {
    const wsUri = 'ws://localhost:1234/binance';
    const connection = new WebSocket(wsUri);

    connection.onopen = session => {
        console.log('Account info WS connected');
    };

    connection.onmessage = message => {
        console.log('Account info message: ', message);
        elmApp.ports.accountInfoRecieved.send(message);
    };

};
