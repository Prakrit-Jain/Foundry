// SPDX-License-Identifier: MIT
pragma solidity =0.8.18;

import "../node_modules/@openzeppelin/contracts/proxy/Clones.sol";
import "./ERC20Token.sol";

contract ERC20Factory {
    using Clones for address;

    /**
     * @notice Fee rate equivalent
     * @dev Stores the FixedValue in bytecode
     */
    uint256 constant FEES_MANAGER = 3;

    /**
     * @notice Refferal Fee rate equivalent
     * @dev Stores the FixedValue in bytecode
     */
    uint256 constant REFFERAL_MANAGER = 2;

    /**
     * @notice decimals value for the fees deduction
     * @dev Stores the decimal value in bytecode
     */
    uint256 constant DECIMALS = 4;

    /**
     * @notice boolean initially set to true means fee_manager dedution.
     */
    bool private mode = true;

    /**
     * @notice implementation address to be used to create clone.
     * @dev As it will be same , taking it as immutable , store in bytecode.
     */
    address private immutable _implementation;

    /**
     * @notice owner address.
     */
    address public _owner;

    /**
     * @dev Event Emmited when clone is successfully created having msg.sender address\
     *  and minimal proxy address as argument.
     */
    event Cloned(address, address);

    /**
     * @dev Event Emmited when FeeMode is changed from `from` to `to`.
     */
    event ModeChanged(uint from, uint to);

    /**
     * @dev Sets the deployer as msg.sender.
     * alaso sets the implementation contract address to be used for creating clone.
     */
    constructor(address implementation_) {
        _owner = msg.sender;
        _implementation = implementation_;
    }

    /**
     * @dev Modifier for checking the only owner address i.e who have deployed the contract.
     */
    modifier onlyOwner() {
        require(msg.sender == _owner, "Not a owner");
        _;
    }

    /**
     * @notice Returns the current fee rate based on the fee mode.
     * @dev Returns 3 if `mode` is true (FEE_manager i.e 0.0003% fee will be deducted),
     * 2 otherwise (REFFERAL_manager i.e 0.0002% fee will be deducted).
     * @return uint The current fee rate as an unsigned integer.
     */
    function checkFeeRate() external view returns (uint256) {
        if (mode == true) {
            return 3;
        } else {
            return 2;
        }
    }

    /**
     * @notice Changes the fee mode between standard and referral.
     * @dev Only owner can change the fee mode
     * emit Modechanged event
     */
    function changeFeeMode() external onlyOwner {
        if (mode == true) {
            mode = false;
            emit ModeChanged(3, 2);
        } else {
            mode = false;
            emit ModeChanged(2, 3);
        }
    }

    /**
     * @notice Creates a new ERC20 token Clone using the create opcode from Clones oz library
     * @dev Deploys a new minimal proxy contract that clones the implementation contract.
     * Fees is send to owner of the Factory Contract according to the mode.
     * Later Transfers ownership of the token to the caller of the function.
     * @param name The name of the new ERC20 token.
     * @param symbol The symbol of the new ERC20 token.
     * @param initialSupply The initial supply of the new ERC20 token.
     */
    function createERC20Proxy(string memory name, string memory symbol, uint256 initialSupply)
        external
        returns (address minimalProxy)
    {
        minimalProxy = _implementation.clone();
        ERC20Token tokenInstance = ERC20Token(minimalProxy);
        tokenInstance.initialize(name, symbol, initialSupply);
        uint256 fees;
        if (mode == true) {
            fees = (initialSupply * FEES_MANAGER) / (10 ** DECIMALS);
        } else {
            fees = (initialSupply * REFFERAL_MANAGER) / (10 ** DECIMALS);
        }
        tokenInstance.transfer(_owner, fees);
        tokenInstance.transfer(msg.sender, initialSupply - fees);
        tokenInstance.transferOwner(msg.sender);
        emit Cloned(msg.sender, minimalProxy);
    }
}
