// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract MockOracle {
    uint private productionData;
    uint private consumptionData;
    
    // Set test data
    function setEnergyData(uint _production, uint _consumption) external {
        productionData = _production;
        consumptionData = _consumption;
    }
    
    // Implements the IOracle interface
    function getEnergyData() external view returns (uint production, uint consumption) {
        return (productionData, consumptionData);
    }
}
