### Mirror721

Mirror721 is a token standard derived from ERC721 that uses [Wormhole](https://github.com/wormhole-foundation/wormhole) as a messaging layer to reflect state across EVM chains. Updates to state such as mints and transfer brodcast messages to the Wormhole network that can be replayed across chains. No one chain has authority over others and updates can be initiated from any chain in the loop. For more details please see the [Presentation](https://github.com/0x0aa0/Mirror721/blob/main/MIRROR.pdf)

### Setup

To run the scripts provided you will need to install [Foundry](https://github.com/foundry-rs/foundry) and set up am env file with a private key and derived public key

### Deployment

Mirror721 utilizes [CREATE3Factory](https://github.com/ZeframLou/create3-factory) to deploy contracts at the same address across chains. Once Factories are deployed on relevant chains you can retrieve the unique token contract bytecodes with a dry run of [Implementation](https://github.com/0x0aa0/Mirror721/blob/main/script/Implementation.s.sol) and then deploy that bytecode using [CREATE3](https://github.com/0x0aa0/Mirror721/blob/main/script/CREATE3.s.sol)

### Initiate Update

Using the RPC of the chain that you would like to initate the update from, run [Start](https://github.com/0x0aa0/Mirror721/blob/main/script/Start.s.sol) to mint or [StartTransfer](https://github.com/0x0aa0/Mirror721/blob/main/script/StartTransfer.s.sol) to trasnfer

### Reflect Update

After initating an update you will need to retrive the signed VAA from Wormhole using [VAA](https://github.com/0x0aa0/Mirror721/blob/main/script/VAA.py) and then pass that VAA to the next contract using either [Validate](https://github.com/0x0aa0/Mirror721/blob/main/script/Validate.s.sol) or [ValidateTransfer](https://github.com/0x0aa0/Mirror721/blob/main/script/ValidateTransfer.s.sol) as relevant. 
