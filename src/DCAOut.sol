// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./DCAStrategy.sol"; 

contract DCAOut is AutomationCompatibleInterface, Ownable {
    DCAStrategy public dcaStrategy;
    AggregatorV3Interface public priceFeed;
    address public chainlinkAutomationRegistry;

    struct DCAOutConfig {
        address outToken;
        uint256 priceTarget;
        uint256 frequency;
        uint256 nextExecution;
        bool paused;
    }

    mapping(address => DCAOutConfig) public userDCAOutConfig;
    address[] public users; // To keep track of users for upkeep checks

    event DCAOutStrategySet(address indexed user, address indexed outToken, uint256 priceTarget, uint256 frequency);
    event DCAOutPaused(address indexed user);
    event DCAOutResumed(address indexed user);
    event ProfitsRealized(address indexed user, uint256 amount);

    constructor(
        address _dcaStrategy,
        address _priceFeed,
        address _chainlinkAutomationRegistry
    ) Ownable(msg.sender){
        dcaStrategy = DCAStrategy(_dcaStrategy);
        priceFeed = AggregatorV3Interface(_priceFeed);
        chainlinkAutomationRegistry = _chainlinkAutomationRegistry;
    }

    function setDCAOutStrategy(address outToken, uint256 priceTarget, uint256 frequency) external {
        userDCAOutConfig[msg.sender] = DCAOutConfig({
            outToken: outToken,//only supports eth for now
            priceTarget: priceTarget,
            frequency: frequency,
            nextExecution: block.timestamp + frequency,
            paused: false
        });

        // Add user to users array if this is their first strategy
        if (userDCAOutConfig[msg.sender].frequency == frequency) {
            users.push(msg.sender);
        }

        emit DCAOutStrategySet(msg.sender, outToken, priceTarget, frequency);
    }

    function pauseDCAOut() external {
        userDCAOutConfig[msg.sender].paused = true;
        emit DCAOutPaused(msg.sender);
    }

    function resumeDCAOut() external {
        userDCAOutConfig[msg.sender].paused = false;
        emit DCAOutResumed(msg.sender);
    }

    function checkUpkeep(bytes calldata /* checkData */)
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        for (uint256 i = 0; i < users.length; i++) {
            address userAddress = users[i];
            DCAOutConfig memory config = userDCAOutConfig[userAddress];
            if (!config.paused && block.timestamp >= config.nextExecution) {
                // Get the current price
                (, int256 price, , , ) = priceFeed.latestRoundData();
                if (price >= int256(config.priceTarget)) {
                    upkeepNeeded = true;
                    performData = abi.encode(userAddress);
                    return (upkeepNeeded, performData);
                }
            }
        }
        upkeepNeeded = false;
    }

    function performUpkeep(bytes calldata performData) external override {
        address userAddress = abi.decode(performData, (address));
        DCAOutConfig storage config = userDCAOutConfig[userAddress];
        if (block.timestamp >= config.nextExecution && !config.paused) {
            // Get the current price
            (, int256 price, , , ) = priceFeed.latestRoundData();
            if (price >= int256(config.priceTarget)) {
                // Realize profits by withdrawing from DCAStrategy
                
                (address token, uint256 amount) = dcaStrategy.getuserbalance(userAddress);
                if (amount > 0) {
                    dcaStrategy.takeProfits(token,amount);
                }

                // Update next execution time
                config.nextExecution = block.timestamp + config.frequency;
            }
        }
    }
}
