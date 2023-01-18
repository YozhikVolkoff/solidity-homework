// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
import "./Owner.sol";
import "./StandardToken.sol";
import "./StakerNFT.sol";

contract Staker is StakerNFT {
    using SafeMath for uint256;  

    event TimeIsOver();
    event SuccessHasCome();

    uint deployDate;
    uint constant collectStackTime = 1 minutes;
    uint constant successThreshold = 0.5 ether;
    uint constant bronzeLimit = 0.25 ether;
    uint constant silverLimit = 0.5 ether;
    uint constant goldLimit = 0.75 ether;
    address refundAddress;

    mapping (address => uint) balances;
    address[] usersAddressesList;
    uint totalBalance = 0;
    bool public success = false;
    bool public active = true;

    constructor() {
        assert(getOwner() == msg.sender);
        refundAddress = getOwner();
        deployDate = block.timestamp;
    }

    modifier allowWithdraw() {
        if (active)
        {
            bool soWhat = _isTimeElapsed();
            if (soWhat)
            {
                _closeContract();
            }
        }
        require (!success && !active, "Withdraw is not allowed.");
        _;
    }

    modifier isActive() {
        require(active, "Contract is not active now.");
        _;
    }

    function _closeContract() internal {
        active = false;
        if (address(this).balance > successThreshold)
        {
            success = true;

            // take tokens to all users
            for (uint ii = 0; ii < usersAddressesList.length; ii++)
            {
                address user = usersAddressesList[ii];
                if (balances[user] >= goldLimit)
                {
                    produceToken(user, "Gold");                    
                }
                else if (balances[user] >= silverLimit)
                {
                    produceToken(user, "Silver");                    
                }
                else if (balances[user] >= bronzeLimit)
                {
                    produceToken(user, "Bronze"); 
                }
            }

            payable(refundAddress).transfer(address(this).balance);            
            emit SuccessHasCome();
        }
        emit TimeIsOver();
    }

    function _isTimeElapsed() internal view returns (bool) {
        return (block.timestamp >= deployDate + collectStackTime);
    }

    function changeRefundAddress(address _newAddr) public isOwner {
        refundAddress = _newAddr;
    }

    function checkIsTimeElapsed() public returns (bool) {
        bool soWhat = _isTimeElapsed();
        if (soWhat) {
            _closeContract();
        }

        return soWhat; 
    }

    function getUserTokens() external payable isActive {
        bool soWhat = _isTimeElapsed();
        if (soWhat)
        {
            _closeContract();
            revert("Time for collecting ethers has expired!");
        }

        // new user has arrived
        if (balances[msg.sender] == 0)
        {
            usersAddressesList.push(msg.sender);
        }
        balances[msg.sender] = balances[msg.sender].add(msg.value);
        totalBalance = totalBalance.add(msg.value);
    }

    function withdraw() external allowWithdraw {
        require(balances[msg.sender] > 0, "You have not ethers in this contract.");

        payable(msg.sender).transfer(balances[msg.sender]);
        totalBalance = totalBalance.sub(balances[msg.sender]);
        balances[msg.sender] = 0;    
    }
}
