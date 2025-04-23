// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Script, console, stdJson} from "forge-std/Script.sol";
import {SimpleTokenReceiver} from "../../../src/SimpleTokenReceiver.sol";
import {WarpMessengerMock} from "../../mock/WarpMessengerMock.sol";

/**
 * To run this script:
 * forge script script/basic/deployment/DeploySimpleTokenReceiver.sol:DeploySimpleTokenReceiver --rpc-url $COQNET_RPC_URL --account deployer --broadcast -vvvv --verifier custom --verify --verifier-url 'https://api.routescan.io/v2/network/mainnet/evm/42069/etherscan' --etherscan-api-key "verifyContract"
 */
contract DeploySimpleTokenReceiver is Script {
    string constant ADDRESSES_FILE = "script/addresses.json";

    using stdJson for string;

    function run() external {
        console.log("Deploying SimpleTokenReceiver...");

        vm.startBroadcast();
        SimpleTokenReceiver receiver = new SimpleTokenReceiver();
        vm.stopBroadcast();

        address receiverAddress = address(receiver);
        console.log("\n=== Deployment Summary ===");
        console.log("SimpleTokenReceiver Address:", receiverAddress);

        vm.writeJson(vm.toString(receiverAddress), ADDRESSES_FILE, ".tokenReceiverAddress");
    }
}
