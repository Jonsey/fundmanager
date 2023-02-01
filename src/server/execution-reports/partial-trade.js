const partialTrade = msg => {
    return {
        id: msg.tradeId,
        eventType: 'PARTIAL_TRADE',
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

export default partialTrade;
