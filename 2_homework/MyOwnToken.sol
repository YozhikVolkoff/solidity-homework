// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
import "./StandardToken.sol";
import "./Owner.sol";

contract MyOwnToken is StandardToken, Owner {
    using SafeMath for uint256;    
    string constant public name = "My Own Token";
    string constant public symbol = "MOWNTOKEN";
    uint constant public decimals = 18;
    uint public hardcap = 7777;
    uint MOWNTOKENPrice = 0.0001 ether;

    event Mint(address indexed to, uint256 amount);
    
    event MintFinished();

    bool public mintingFinished = false;

    modifier mintingInProcess() {
        require(!mintingFinished);
        _;
    }

    function buyTokens() public payable mintingInProcess {
        uint tokens_amount = (msg.value).div(MOWNTOKENPrice);
        uint refund = (msg.value).sub( (tokens_amount.mul(MOWNTOKENPrice)) );
        uint refundTokens = _mint(tokens_amount);
        refund = refund.add( (refundTokens.mul(MOWNTOKENPrice)) );

        if (refund > 0)
        {
            payable(msg.sender).transfer(refund);
        }

        address contractOwner = getOwner();
        payable(contractOwner).transfer(address(this).balance);
    }

    function _mint(uint256 _amount) internal returns (uint) {
        uint refund = 0;
        bool stopICO = false;

        if (totalSupply.add(_amount) >= hardcap)
        {
            refund = _amount.sub(hardcap.sub(totalSupply));
            _amount = hardcap.sub(totalSupply);
            stopICO = true;
        }

        if (_amount > 0)
        {
            totalSupply = totalSupply.add(_amount);
            balances[msg.sender] = balances[msg.sender].add(_amount);
            emit Mint(msg.sender, _amount);
        }

        if (stopICO)
        {
            _stopMinting();
        }

        return refund;
    }

    function _stopMinting() internal returns (bool) {
        mintingFinished = true;
        _getReward();
        emit MintFinished();
        return true;
    }

    function finishMinting() public onlyOwner mintingInProcess returns (bool) {
        _stopMinting();
        return true;
    }

    // Transfer 10 % to owner of smart contract
    function _getReward() internal {
        uint reward = totalSupply.div(10);
        address _owner = getOwner();
        balances[_owner] = balances[_owner].add(reward);
    }

}
