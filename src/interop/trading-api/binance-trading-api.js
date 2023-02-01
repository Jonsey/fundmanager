

const tradingApi = (elmApp) => {
  // Outgoing
  elmApp.ports.exchangeRequest.subscribe(function(message) {
    const messageObject = JSON.parse(message);

    switch(messageObject.event) {
      case "requestExchangeInfo":
        requestExchangeInfo(messageObject);
      case "requestPairTradeHistory":
        requestPairTradeHistory(messageObject);
        break;
      case "requestAllTradeHistory":
        requestAllTradeHistory(messageObject);
        break;
      case "requestCompleteBalances":
        requestCompleteBalances(messageObject);
        break;
      case "requestOpenOrders":
        requestOpenOrders(messageObject);
        break;
      case "requestAvailableAccountBalances":
        requestAvailableAccountBalances(messageObject);
        break;
      case "requestAvailableAccountBalance":
        requestAvailableAccountBalance(messageObject);
        break;
      case "requestBuy":
        requestBuy(messageObject);
        break;
      case "requestSell":
        requestSell(messageObject);
        break;
      case "requestMoveOrder":
        requestMoveOrder(messageObject);
        break;
      case "requestCancelOrder":
        requestCancelOrder(messageObject);
        break;
      default:
        console.log(messageObject);
    }
  })

  const requestExchangeInfo = (messageObject) => {

  }
}
