const order = msg => {
    return {
        pairId: msg.symbol,
        orderId: msg.orderId,
        eventType : 'ORDER',
        orderType: msg.side,
        time: parseFloat(msg.orderTime),
        quantity: parseFloat(msg.quantity),
        price: parseFloat(msg.price),
        executionType: msg.executionType,
        orderStatus: msg.orderStatus,
        orderRejectReason: msg.orderRejectReason
    };
};

export default order;

// {"pairId":"GTOBTC","orderId":11752218,"eventType":"ORDER","side":"SELL","quantity":239,"orderStatus":"NEW","orderRejectReason":"NONE"}

// { eventType: 'executionReport',
//   eventTime: 1524775789992,
//   symbol: 'GTOBTC',
//   newClientOrderId: 'web_c0a078f8c5ca456da5870c16e644bfd2',
//   side: 'SELL',
//   orderType: 'LIMIT',
//   timeInForce: 'GTC',
//   quantity: '239.00000000',
//   price: '0.00004705',
//   executionType: 'NEW',
//   orderStatus: 'NEW',
//   orderRejectReason: 'NONE',
//   orderId: 11752218,
//   orderTime: 1524775789996,
//   lastTradeQuantity: '0.00000000',
//   totalTradeQuantity: '0.00000000',
//   priceLastTrade: '0.00000000',
//   commission: '0',
//   commissionAsset: null,
//   tradeId: -1,
//   isBuyerMaker: false }
