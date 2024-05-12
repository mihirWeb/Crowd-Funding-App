// it will help us to identify the address for price feed automatically we need as per the chain we are using 
// i will also create a mock price feed in anvil

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "chainlink-brownie-contracts/contracts/src/v0.8/tests/MockV3Aggregator.sol";

contract HelperConfig is Script{

    NetworkConfig public activeNetworkConfig;
    uint8 public constant DECIMAL = 8;
    int256 public constant INITIAL_PRICE = 2000e8;
 
    struct NetworkConfig{
        address priceAdd; 
    }

    

    constructor() {
        if(block.chainid == 11155111){
            activeNetworkConfig = getSapoliaAdd();
        }
        else if(block.chainid == 1){
            activeNetworkConfig = getEthAdd();
        }
        else{
            activeNetworkConfig = createAnvilAdd();
        }
    }


    function getSapoliaAdd() public pure returns(NetworkConfig memory){
        NetworkConfig memory sapoliaConfig = NetworkConfig({
            priceAdd: 0x694AA1769357215DE4FAC081bf1f309aDC325306 
        });

        return sapoliaConfig;
    }

    function getEthAdd() public pure returns(NetworkConfig memory){
        NetworkConfig memory ethConfig = NetworkConfig({
            priceAdd: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });

        return ethConfig;
    }

    function createAnvilAdd() public returns(NetworkConfig memory){

        if(activeNetworkConfig.priceAdd != address(0)){
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(
            DECIMAL,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilNetwork = NetworkConfig({
            priceAdd: address(mockV3Aggregator)
        });

        return anvilNetwork;

    }
}