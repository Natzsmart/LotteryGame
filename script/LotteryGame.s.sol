// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/LotteryGame.sol";

contract LotteryGameScript is Script {
    function run() external {
        vm.startBroadcast();

        LotteryGame game = new LotteryGame();
        console.log("LotteryGame deployed at:", address(game));

        vm.stopBroadcast();
    }
}