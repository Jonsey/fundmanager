const trade = msg => {
    return {
        id: msg.tradeId,
        eventType: 'TRADE',
        orderType: msg.orderType,
        pairId: msg.symbol,
        side: msg.side,
        orderId: msg.orderId,
        tradeId: msg.tradeId,
        orderStatus: msg.orderStatus,
        price: parseFloat(msg.priceLastTrade),
        lastTradeQuantity: parseFloat(msg.lastTradeQuantity),
        priceLastTrade: parseFloat(msg.priceLastTrade),
        quantity: parseFloat(msg.quantity),
        commission: parseFloat(msg.commission),
        commissionAsset: msg.commissionAsset,
        time: parseFloat(msg.orderTime),
    };
};

export default trade;

// { eventType: 'executionReport',
//   eventTime: 1523657949270,
//   symbol: 'CDTBTC',
//   newClientOrderId: 'web_383964e35b674d309572ae5266962e79',
//   side: 'SELL',
//   orderType: 'MARKET',
//   timeInForce: 'GTC',
//   quantity: '1995.00000000',
//   price: '0.00000000',
//   executionType: 'TRADE',
//   orderStatus: 'FILLED',
//   orderRejectReason: 'NONE',
//   orderId: 7815881,
//   orderTime: 1523657949266,
//   lastTradeQuantity: '1995.00000000',
//   totalTradeQuantity: '1995.00000000',
//   priceLastTrade: '0.00000572',
//   commission: '0.00326516',
//   commissionAsset: 'BNB',
//   tradeId: 1404215,
//   isBuyerMaker: false }
