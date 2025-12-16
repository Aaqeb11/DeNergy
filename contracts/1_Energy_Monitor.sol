// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IOracle {
 function getEnergyData() external view returns (uint production, uint consumption) ;  
}

contract EnergyMonitor {
    IOracle private oracle;
    
    constructor(address oracleAddress){
        oracle = IOracle(oracleAddress);
    }

    function checkExcessEnergy() external view returns (bool hasExcess, uint excessAmount) {
        (uint production, uint consumption) = oracle.getEnergyData();

        if(production>consumption){
            return (true, production - consumption);
        }
        return (false,0);
    }
}