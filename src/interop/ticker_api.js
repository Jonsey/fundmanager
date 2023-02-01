var Socket = require("phoenix-socket").Socket;


const tickerApi = (elmApp) => {

    try {
        var socket = new Socket("ws://localhost:4000/socket");
        socket.connect();

        const tickerChannel = socket.channel("ticker:lobby", {});

        tickerChannel.join()
            .receive("ok", resp => { console.log("Joined Ticker Channel lobby successfully", resp) })
            .receive("error", resp => { console.log("Unable to join", resp) })

        // Incoming
        tickerChannel.on('tickerReceived', pl => {
            // console.log(pl)
        });
    } catch (e) {
        console.log("Error in ticker api: ", e)
    } finally {

    }
}

export default tickerApi;
