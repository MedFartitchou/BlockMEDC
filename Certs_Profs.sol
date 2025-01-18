pragma solidity ^0.8.0;
import {SharedStructs} from "./Structs.sol";
contract Certs_Profs{
 
    address private head ;
    address private A_insti ;
    address private owner;
    bool public valid; // State variable to track the validity of the diploma

   SharedStructs.Prdiploma private diplomas;
    modifier onlyGiver  {
        require(msg.sender == head);
        _;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
 
    constructor (address st,address Ainst,address inst)   {
        require(st !=address(0x0) && Ainst !=address(0x0) && inst !=address(0x0)); 
        
        diplomas.receiver = st;
        diplomas.issuer_Institution = Ainst;
        diplomas.issuer_head = inst;
        owner = st;
        A_insti  = Ainst;
        head = inst;
        valid = true; // Set the diploma as valid when issued
    }

    event PrCertIssued(address from,address from1, address to, uint date);
    function emitt() public {
        diplomas.date = block.timestamp;
        diplomas.status = true;
        emit PrCertIssued(diplomas.issuer_Institution , diplomas.issuer_head, diplomas.receiver, diplomas.date);
    }
    event Revoked(address from, uint256 date);
   function revoke() public onlyGiver {
        valid = false; // Mark the diploma as invalid when revoked
        emit Revoked(head, block.timestamp);
    }

    /// @notice Check if the diploma is still valid
    function isValid() public view returns (bool) {
        return valid;
    }

    /// @notice Fallback function to accept Ether if sent directly to the contract
    receive() external payable {}
}
