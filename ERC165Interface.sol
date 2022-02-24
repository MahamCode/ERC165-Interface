// Store.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./ERC165/ERC165.sol";

// StoreInterface Id

abstract contract StoreInterfaceId {
  function calcStoreInterfaceId() public pure virtual returns(bytes4){
    StoreInterface i;
    //return i.getValue.selector ^ i.setValue.selector;
    return i.getValue.selector ^ i.setValue.selector ^ i.getValueAgain.selector;
  }
  bytes4 internal STORE_INTERFACE_ID = calcStoreInterfaceId();
}

// StoreInterface 

abstract contract StoreInterface is StoreInterfaceId{
  function getValue() external view virtual returns (uint256);
  function getValueAgain() external view virtual returns (uint256);
  function setValue(uint256 v) external virtual;
}

// Main Contract

contract Store is ERC165, StoreInterface {
  uint256 internal value;  
  function setValue(uint256 v) external override{
    value = v;
  }  
  function getValue() external view override returns (uint256) {
    return value;
  }  
  function getValueAgain() external view override returns (uint256) {
    return value;
  }  
  function calcStoreInterfaceId() public pure override returns(bytes4){

    return super.calcStoreInterfaceId();
  }
  function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {
  //0x01ffc9a7 represents that it's the ERC165 Interface Implementation
    return interfaceId == 0x01ffc9a7 || interfaceId == calcStoreInterfaceId();
  }
   
}

// Main Contract Reader

import "./ERC165/ERC165Query.sol";

contract StoreReader is StoreInterfaceId, ERC165Query{
    StoreInterface store;
    constructor (address storeAddress) {
        require(doesContractImplementInterface(
        storeAddress, STORE_INTERFACE_ID), 
        "Doesn't support StoreInterface");    
        store = StoreInterface(storeAddress);
    }  
    function readStoreValue() external view returns (uint256) {
        return store.getValue();
    }
}

/*With the above implementation, `StoreReader` is able to avoid reading values from contracts that 
don’t support `StoreInterface`. */


										//MAKE NEW FOLDER with name of ERC165 and add the below files in it


                                                                             //ERC165Query.sol 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC165Query {
    bytes4 constant InvalidID = 0xffffffff;
    bytes4 constant ERC165ID = 0x01ffc9a7;

    function doesContractImplementInterface(address _contract, bytes4 _interfaceId) internal view returns (bool) {
        uint256 success;
        uint256 result;

        (success, result) = noThrowCall(_contract, ERC165ID);
        if ((success==0)||(result==0)) {
            return false;
        }

        (success, result) = noThrowCall(_contract, InvalidID);
        if ((success==0)||(result!=0)) {
            return false;
        }

        (success, result) = noThrowCall(_contract, _interfaceId);
        if ((success==1)&&(result==1)) {
            return true;
        }
        return false;
    }

    function noThrowCall(address _contract, bytes4 _interfaceId) view internal returns (uint256 success, uint256 result) {
        bytes4 erc165ID = ERC165ID;

        assembly {
                let x := mload(0x40)               // Find empty storage location using "free memory pointer"
                mstore(x, erc165ID)                // Place signature at beginning of empty storage
                mstore(add(x, 0x04), _interfaceId) // Place first argument directly next to signature

                success := staticcall(
                                    30000,         // 30k gas
                                    _contract,     // To addr
                                    x,             // Inputs are stored at location x
                                    0x24,          // Inputs are 36 bytes long
                                    x,             // Store output over input (saves space)
                                    0x20)          // Outputs are 32 bytes long

                result := mload(x)                 // Load the result
        }
    }
}



								//ERC165
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ERC165 {
  function supportsInterface(bytes4 interfaceID) 
    external view returns (bool);
}



