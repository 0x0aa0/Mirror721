### Foundry

To run the scripts provided you will need to install [Foundry](https://github.com/foundry-rs/foundry). See the [installation guide](https://github.com/foundry-rs/foundry#installation) for details.

### Mirror721

Mirror721 is a token standard derived from ERC721 that uses [Wormhole](https://github.com/wormhole-foundation/wormhole) as a messaging layer to reflect state across EVM chains. Updates to state such as mints and transfer brodcast messages to the Wormhole network that can be replayed across chains. No one chain has authority over others and updates can be initiated from any chain in the loop. 
