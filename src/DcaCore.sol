// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AutomationCompatible} from "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";
import {IPool} from "@aave/core-v3/contracts/interfaces/IPool.sol";
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract DCAStrategy is AutomationCompatible, Ownable {
    IPool public aavePool;
    ISwapRouter public uniswapRouter;
    address public chainlinkAutomationRegistry;

    struct DCAConfig {
        address inToken; // Token deposited by the user
        address outToken;
        uint256 dcaAmount;
        uint256 frequency;
        uint256 nextExecution;
        bool paused;
    }

    mapping(address => mapping(address => uint256)) public userBalances; // user -> token -> amount
    mapping(address => DCAConfig) public userDCAConfig;
    address[] public users; // To keep track of users for upkeep checks

    event Deposited(address indexed user, address indexed token, uint256 amount);
    event Withdrawn(address indexed user, address indexed token, uint256 amount);
    event StrategySet(address indexed user, address indexed outToken, uint256 dcaAmount, uint256 frequency);
    event DCAPaused(address indexed user);
    event DCAResumed(address indexed user);
    event DCAExecuted(address indexed user, uint256 amountIn, uint256 amountOut);
    event ProfitsRealized(address indexed user, uint256 amount);
    event WithdrawnfromPool(address indexed user, address token, uint256 amount);

    constructor(
        address _aavePool,
        address _uniswapRouter,
        address _chainlinkAutomationRegistry
    ) Ownable(msg.sender){
        aavePool = IPool(_aavePool);
        uniswapRouter = ISwapRouter(_uniswapRouter);
        chainlinkAutomationRegistry = _chainlinkAutomationRegistry;
    }

    function deposit(address token, uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        IERC20(token).approve(address(aavePool), amount);
        aavePool.supply(token, amount, address(this), 0);
        userBalances[msg.sender][token] += amount;

        // Add user to users array if this is their first deposit
        if (userBalances[msg.sender][token] == amount) {
            users.push(msg.sender);
        }

        emit Deposited(msg.sender, token, amount);
    }

    function withdraw(address token, uint256 amount) external {
        require(userBalances[msg.sender][token] >= amount, "Insufficient balance");
        userBalances[msg.sender][token] -= amount;
        aavePool.withdraw(token, amount, msg.sender);
        emit WithdrawnfromPool(msg.sender, token, amount);
    }

    function setDCA(address outToken, uint256 dcaAmount, uint256 frequency) external {
        address inToken = getUserDepositedToken(msg.sender);
        require(inToken != address(0), "No tokens deposited");

        userDCAConfig[msg.sender] = DCAConfig({
            inToken: inToken,
            outToken: outToken,
            dcaAmount: dcaAmount,
            frequency: frequency,
            nextExecution: block.timestamp + frequency,
            paused: false
        });

        emit StrategySet(msg.sender, outToken, dcaAmount, frequency);
    }

    function pauseDCA() external {
        userDCAConfig[msg.sender].paused = true;
        emit DCAPaused(msg.sender);
    }

    function resumeDCA() external {
        userDCAConfig[msg.sender].paused = false;
        emit DCAResumed(msg.sender);
    }

    function checkUpkeep(bytes calldata /* checkData */)
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        for (uint256 i = 0; i < users.length; i++) {
            address userAddress = users[i];
            DCAConfig memory config = userDCAConfig[userAddress];
            if (!config.paused && block.timestamp >= config.nextExecution) {
                upkeepNeeded = true;
                performData = abi.encode(userAddress);
                return (upkeepNeeded, performData);
            }
        }
        upkeepNeeded = false;
    }

    function performUpkeep(bytes calldata performData) external override {
        address userAddress = abi.decode(performData, (address));
        DCAConfig storage config = userDCAConfig[userAddress];
        if (block.timestamp >= config.nextExecution && !config.paused) {
            uint256 amountIn = config.dcaAmount;
            address tokenIn = config.inToken;
            require(userBalances[userAddress][tokenIn] >= amountIn, "Insufficient balance for DCA");

            // Withdraw from Aave
            aavePool.withdraw(tokenIn, amountIn, address(this));
            IERC20(tokenIn).approve(address(uniswapRouter), amountIn);

            // Swap on Uniswap
            ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: config.outToken,
                fee: 3000,
                recipient: userAddress,
                deadline: block.timestamp + 60,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
            uint256 amountOut = uniswapRouter.exactInputSingle(params);

            // Update balances and next execution time
            userBalances[userAddress][tokenIn] -= amountIn;
            config.nextExecution = block.timestamp + config.frequency;

            emit DCAExecuted(userAddress, amountIn, amountOut);
        }
    }
   
      function takeProfits(address token, uint256 amount) external {
        require(userBalances[msg.sender][token] >= amount, "Insufficient balance");
        userBalances[msg.sender][token] -= amount;
        address user = payable(msg.sender);
        IERC20(token).transfer(user, amount);
        emit ProfitsRealized(user, amount);

    }


    function getUserDepositedToken(address userAddress) public view returns (address) {
        // This function should return the token address that the user has deposited.
        // We assume here that users can only deposit one type of token.
        for (uint256 i = 0; i < users.length; i++) {
            address token = users[i];
            if (userBalances[userAddress][token] > 0) {
                return token;
            }
        }
        return address(0);
    }
    function getuserbalance(address userAddress) public view returns (address , uint256) {
     {
        address token = getUserDepositedToken(userAddress);
        uint256 bal = userBalances[userAddress][token];
        return (token,bal);    

    }
}

 }
