var Socket = require("phoenix-socket").Socket;


const tradingApi = (elmApp) => {

    try {
        var socket = new Socket("ws://localhost:4000/socket");
        socket.connect();

        const exchangeChannel = socket.channel("exchange:lobby", {});

        exchangeChannel.join()
            .receive("ok", resp => { console.log("Joined Exchange Channel lobby successfully", resp) })
            .receive("error", resp => { console.log("Unable to join", resp) })

        // Incoming
        exchangeChannel.on('trades:receive_all_my_history', pl => {
            Object.entries(pl).forEach(([key, value]) => {
                console.log(`${key} ${value}`);
                const pairId = key;

                value.map(t => {
                    const trade = {
                        id : t.tradeID,
                        date : t.date,
                        rate : parseFloat(t.rate),
                        amount : parseFloat(t.amount),
                        total : parseFloat(t.total),
                        fee : parseFloat(t.fee),
                        orderNumber : t.orderNumber,
                        tradeType : t.type,
                        category : t.category,
                        pairId : pairId
                    };

                    elmApp.ports.tradeReceived.send(trade)
                })
            });

            console.log(pl)
        })

        // Outgoing
        elmApp.ports.exchangeRequest.subscribe(function(message) {
            const messageObject = JSON.parse(message);

            switch(messageObject.event) {
            case "requestPairTradeHistory":
                requestPairTradeHistory(exchangeChannel, messageObject);
                break;
            case "requestAllTradeHistory":
                requestAllTradeHistory(exchangeChannel, messageObject);
                break;
            case "requestCompleteBalances":
                requestCompleteBalances(exchangeChannel, messageObject);
                break;
            case "requestOpenOrders":
                requestOpenOrders(exchangeChannel, messageObject);
                break;
            case "requestAvailableAccountBalances":
                requestAvailableAccountBalances(exchangeChannel, messageObject);
                break;
            case "requestAvailableAccountBalance":
                requestAvailableAccountBalance(exchangeChannel, messageObject);
                break;
            case "requestBuy":
                requestBuy(exchangeChannel, messageObject);
                break;
            case "requestSell":
                requestSell(exchangeChannel, messageObject);
                break;
            case "requestMoveOrder":
                requestMoveOrder(exchangeChannel, messageObject);
                break;
            case "requestCancelOrder":
                requestCancelOrder(exchangeChannel, messageObject);
                break;
            default:
                console.log(messageObject);
            }
        })
    } catch (e) {
        console.log("Error in trading api: ", e)
    } 

}

const requestPairTradeHistory = (exchangeChannel, messageObject) => {
    const pairId = messageObject.pair_id;
    const payload = {
        "payload": { "pair_id": pairId }
    }
    console.log(payload)
    exchangeChannel.push("trades:pair_trade_history", payload);
}

const requestAllTradeHistory = (exchangeChannel, messageObject) => {
    const start = messageObject.start;
    const end = messageObject.end;
    const limit = messageObject.limit;
    const payload = {
        "payload": {
            start,
            end,
            limit
        }
    }
    console.log(payload)
    exchangeChannel.push("trades:all_trade_history", payload);
}

const requestCompleteBalances = (exchangeChannel, messageObject) => {
    const payload = {
        "payload": { }
    }
    console.log(payload)
    exchangeChannel.push("trades:complete_balances", payload);
}

const requestOpenOrders = (exchangeChannel, messageObject) => {
    const pairId = messageObject.pair_id;

    const payload = {
        "payload": { "pair_id": pairId }
    }
    console.log(payload)
    exchangeChannel.push("trades:open_orders", payload);
}

const requestAvailableAccountBalances = (exchangeChannel, messageObject) => {

    const payload = {
        "payload": {
        }
    }
    console.log(payload)
    exchangeChannel.push("trades:request_available_account_balances", payload);
}

const requestAvailableAccountBalance = (exchangeChannel, messageObject) => {
    const pairId = messageObject.pair_id;

    const payload = {
        "payload": {
            "account": pairId
        }
    }
    console.log(payload)
    exchangeChannel.push("trades:request_available_account_balance", payload);
}

const requestBuy = (exchangeChannel, messageObject) => {
    const pairId = messageObject.pair_id;
    const rate = messageObject.rate;
    const amount = messageObject.amount;

    const payload = {
        "payload": {
            "pair_id": pairId,
            "rate": rate,
            "amount": amount
        }
    }
    console.log(payload)
    exchangeChannel.push("trades:request_buy", payload);
}

const requestSell = (exchangeChannel, messageObject) => {
    const pairId = messageObject.pair_id;
    const rate = messageObject.rate;
    const amount = messageObject.amount;

    const payload = {
        "payload": {
            "pair_id": pairId,
            "rate": rate,
            "amount": amount
        }
    }
    console.log(payload)
    exchangeChannel.push("trades:request_sell", payload);
}

const requestMoveOrder = (exchangeChannel, messageObject) => {
    const orderNumber = messageObject.order_number;
    const rate = messageObject.rate;
    const amount = messageObject.amount;

    const payload = {
        "payload": {
            "orderNumber": orderNumber,
            "rate": rate,
            "amount": amount
        }
    }
    console.log(payload)
    exchangeChannel.push("trades:request_sell", payload);
}

const requestCancelOrder = (exchangeChannel, messageObject) => {
    const orderNumber = messageObject.order_number;

    const payload = {
        "payload": {
            "orderNumber": orderNumber
        }
    }
    console.log(payload)
    exchangeChannel.push("trades:request_cancel_order", payload);
}

export default tradingApi;
