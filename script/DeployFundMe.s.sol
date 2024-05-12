// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/CrowdFunding.sol";
// import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {

    function run() external returns(FundMe){
        // outside broadcast so that it will not take gas fees 


        // account 2 on my metamask
        uint256 privateKey = vm.envUint("SEPOLIA_PVT_KEY");
        // address account = vm.addr(privateKey);

        // console.log("Account", account);

        // HelperConfig helperConfig = new HelperConfig();
        // address activeNetwork = helperConfig.activeNetworkConfig();


        vm.startBroadcast(privateKey);
        FundMe fundMe = new FundMe();
        vm.stopBroadcast();
        return fundMe;
    }
} 