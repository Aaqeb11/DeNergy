// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IOracle {
 function getEnergyData() external view returns (uint production, uint consumption) ;  
}

interface IEnergyToken {
    function mint(address to, uint256 amount) external;
}

contract EnergyMonitor {
    IOracle private oracle;
    

    IEnergyToken public energyToken;

    address public admin;

    event ExcessDetected(address indexed producer, uint256 excessKWh, uint256 tokensMinted);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    constructor(address oracleAddress, address energyTokenAddress){
        require(oracleAddress != address(0), "Oracle required");
        require(energyTokenAddress != address(0), "Token required");
        admin = msg.sender;
        oracle = IOracle(oracleAddress);
        energyToken = IEnergyToken(energyTokenAddress);
    }
    

    function checkExcessEnergy() public view returns (bool hasExcess, uint excessAmount) {
        (uint production, uint consumption) = oracle.getEnergyData();

        if(production>consumption){
            return (true, production - consumption);
        }
        return (false,0);
    }

    function mintFromExcess(address producer) external {
        require(producer != address(0), "Invalid producer");

        (bool hasExcess, uint256 excessKWh) = checkExcessEnergy();
        require(hasExcess && excessKWh > 0, "No excess energy");

        uint256 amount = excessKWh;

        energyToken.mint(producer, amount);

        emit ExcessDetected(producer, excessKWh, amount);
    }
}