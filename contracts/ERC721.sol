// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Metadata.sol";
import "./Strings.sol";

contract ERC721 is IERC721, IERC721Metadata {
    using Strings for uint;
    string private _name;
    string private _symbol;

    function name() external view returns (string memory) {
      return _name;
    }

    function symbol() external view returns (string memory) {
      return _symbol;
    }

    function _baseURI() internal view virtual returns(string memory) {
      return "";
    }

    function tokenURI(uint tokenId) external view returns(string memory) {
      string memory baseURI = _baseURI();
      return bytes(baseURI).length > 0 ? 
      string(abi.encodePacked(baseURI, tokenId.toString())) : 
      "";
    }
}
