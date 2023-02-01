import { order, trade, partialTrade, rejectedOrder, account } from './execution-reports';

const handleUserData = (msg, socket) => {
    console.log('Handle user data: ', msg);

    const report = {
        executionReport: handleExecutionReport,
        outboundAccountPosition: () => {},
        outboundAccountInfo: () => {},
        balanceUpdate: () => {},
        account: handleAccount,
    };

    let messageType;

    if (msg.type) {
        messageType = msg.type;
    }

    if (msg.eventType) {
        messageType = msg.eventType;
    }

    if (messageType) {
        report[messageType](msg, socket);
    } else {
        console.log('Unknown message: ');
    }
};

const handleExecutionReport = (msg, socket) => {
    try {
        const message = {
            FILLED: trade,
            PARTIALLY_FILLED: partialTrade,
            REJECTED: rejectedOrder,
            NEW: order,
            CANCELED: order,
        };

        const data = message[msg.orderStatus](msg);

        socket.send(JSON.stringify(data));
    } catch (e) {
        console.log("Handle execution report error: ", e);
    }
};

const handleAccount = (msg, socket) => {
    try {
        socket.send(JSON.stringify(account(msg)));
    } catch (e) {
        console.log("Handle account messgae error: ", e);
    }
};

export default handleUserData;
