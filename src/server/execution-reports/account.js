const account = msg => {
    try {
        let balances = [];

        Object.keys(msg.balances).map(key => {
            const balance = msg.balances[key];

            if (balance.available > 0) {
                balances.push({
                    asset : key,
                    free : parseFloat(balance.available),
                    locked : parseFloat(balance.locked)
                });
            }
        });

        return {
            eventType : 'ACCOUNT',
            balances };
    } catch (e) {
        console.log(e);
    }
};

export default account;


// { eventType: 'account',
//   eventTime: 1523657949271,
//   balances:
//    { BTC: { available: '0.01153363', locked: '0.00000000' },
//      LTC: { available: '0.00750891', locked: '0.00000000' },
//      ETH: { available: '0.00000000', locked: '0.00000000' },
//      BNC: { available: '0.00000000', locked: '0.00000000' },
//      ICO: { available: '0.00000000', locked: '0.00000000' },
//  } }
