// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./Owner.sol";
import "./StandardToken.sol";

contract StakerNFT is Owner {
  using SafeMath for uint256;

  event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
  event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
  event newTokenProduced(address _owner, string _status);

  struct stakerToken {
      string status;
  }

  stakerToken[] public stakerTokens;
  uint256 public stakerTokensTotal = 0;

  mapping (address => uint256) public ownerTokensCount;
  mapping (uint256 => address) public tokenToOwner;
  mapping (uint256 => address) public tokenApprovals;

  modifier onlyOwnerOf(uint256 _tokenId) {
      require(msg.sender == tokenToOwner[_tokenId]);
      _;
  }

  function produceToken(address _owner, string memory _status) public onlyOwner {
      stakerToken memory newToken = stakerToken(_status);
      stakerTokens.push(newToken);
      tokenToOwner[stakerTokens.length - 1] = _owner;
      ownerTokensCount[_owner] = ownerTokensCount[_owner].add(1);
      stakerTokensTotal = stakerTokensTotal.add(1);
      emit newTokenProduced(_owner, _status);
  }

  function balanceOf(address _owner) external view returns (uint256) {
    return ownerTokensCount[_owner];
  }

  function ownerOf(uint256 _tokenId) external view returns (address) {
    return tokenToOwner[_tokenId];
  }

  function _transfer(address _from, address _to, uint256 _tokenId) private {
    ownerTokensCount[_to] = ownerTokensCount[_to].add(1);
    ownerTokensCount[msg.sender] = ownerTokensCount[msg.sender].sub(1);
    tokenToOwner[_tokenId] = _to;
    emit Transfer(_from, _to, _tokenId);
  }

  function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
      require (tokenToOwner[_tokenId] == msg.sender || tokenApprovals[_tokenId] == msg.sender);
      _transfer(_from, _to, _tokenId);
    }

  function approve(address _approved, uint256 _tokenId) external payable onlyOwnerOf(_tokenId) {
      tokenApprovals[_tokenId] = _approved;
      emit Approval(msg.sender, _approved, _tokenId);
    }
}