// run this script with truffle exec

const jsonfile = require("jsonfile");
const TokenBridge = artifacts.require("TokenBridge");
const TokenImplementation = artifacts.require("TokenImplementation");
const BridgeImplementationFullABI = jsonfile.readFileSync(
    "../build/contracts/BridgeImplementation.json"
).abi;
const aptosTokenBridgeVAA = process.env.REGISTER_APTOS_TOKEN_BRIDGE_VAA;

module.exports = async function(callback) {
    try {
        const accounts = await web3.eth.getAccounts();
        const initialized = new web3.eth.Contract(
            BridgeImplementationFullABI,
            TokenBridge.address
        );

        // Register the APTOS endpoint
        await initialized.methods
            .registerChain("0x" + aptosTokenBridgeVAA)
            .send({
                value: 0,
                from: accounts[0],
                gasLimit: 2000000,
            });

        callback();
    } catch (e) {
        callback(e);
    }
};
