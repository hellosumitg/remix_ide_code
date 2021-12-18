// SPDX-License_Identifier: MIT

pragma solidity ^0.6.0;

import "./SimpleStorage.sol"; //this is similar to copying the whole code from the "StorageFactory" file

contract StorageFactory is SimpleStorage {
    // Inheritance in solidity by using "is" (i.e inheriting all the functions and variables from "SimpleStorage")

    SimpleStorage[] public simpleStorageArray;

    function createSimpleStorageContract() public {
        SimpleStorage simpleStorage = new SimpleStorage();
        simpleStorageArray.push(simpleStorage);
    }

    function sfStore(uint256 _simpleStorageIndex, uint256 _simpleStorageNumber)
        public
    {
        /* anytime we interact with contract we need two things:-
          1. "address" of the contract we want to interact wiith
          2. ABI or Application Binary interface
        */
        // SimpleStorage simpleStorage = SimpleStorage(address(simpleStorageArray[_simpleStorageIndex]));
        // simpleStorage.store(_simpleStorageNumber);
        SimpleStorage(address(simpleStorageArray[_simpleStorageIndex])).store(
            _simpleStorageNumber
        );
    }

    function sfGet(uint256 _simpleStorageIndex) public view returns (uint256) {
        // SimpleStorage simpleStorage = SimpleStorage(address(simpleStorageArray[_simpleStorageIndex]));
        // return simpleStorage.retrieve();
        return
            SimpleStorage(address(simpleStorageArray[_simpleStorageIndex]))
                .retrieve();
    }
}
