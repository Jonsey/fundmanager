const createAnalysisWebSocket = (elmApp) => {

    const wsUri = 'ws://localhost:8888';
    const connection = new WebSocket(wsUri);

    connection.onopen = function (session) {
        console.log('Analysis Websocket connection opened');
    };

    connection.onmessage = function (message) {
        const data = JSON.parse(message.data);
        const event = data.event;
        const payload = data.payload;

        if (event.split(':')[0] === 'candles') {
            elmApp.ports.analysisReceived.send(payload);
        }

        if (event.split(':')[0] === 'signal') {
            elmApp.ports.analysisReceived.send(payload);
        }
    };
}

export default createAnalysisWebSocket;
