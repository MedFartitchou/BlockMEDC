// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MC_Authority.sol";
import {SharedStructs} from "./Structs.sol";
import "./Certs_Profs.sol";
import "./Certs_Students.sol";

contract University {
    address private owner; // owner == University
    MC_Authority private Autho; // instance of Sc authority
    uint256 private nb_semesters; // number of semesters
    uint256 private total; // total number of semesters

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        require(Autho.isCertificateValid(owner), "Invalid certificate authority");
        _;
    }

    mapping(address => SharedStructs.U_institution) private Institutions;
    mapping(address => bytes32) public studentCertificates;
    mapping(address => bytes32) public professorCertificates;

    constructor(address autho, address university) {
        require(university != address(0), "Invalid university address");
        require(autho != address(0), "Invalid authority address");

        Autho = MC_Authority(autho);
        owner = university;
    }

    event RegisteredIn(address from, address to, uint256 date);

    function AddInstitution(address Institution, address head, address vice_head) public onlyOwner {
        require(Institution != address(0), "Invalid institution address");
        require(!Institutions[Institution].registered, "Institution already registered");

        Institutions[Institution].registered = true;
        Institutions[Institution].head = head;
        Institutions[Institution].vice_head = vice_head;
        emit RegisteredIn(owner, Institution, block.timestamp);
    }

    function CheckInstitution(address ins) public view returns (bool) {
        require(ins != address(0), "Invalid institution address");
        return Institutions[ins].registered;
    }

    function issueDiplomaP(address Uinstitution, address recipient, bool isProfessor) internal onlyOwner {
        require(Uinstitution != address(0), "Invalid institution address");
        require(CheckInstitution(Uinstitution), "Institution not registered");
        require(recipient != address(0), "Invalid recipient address");

        bytes32 signatureHash = keccak256(abi.encodePacked(recipient, Uinstitution, owner, block.timestamp));

        if (isProfessor) {
            Certs_Profs professorDiploma = Certs_Profs(payable(recipient));
            professorDiploma.emitt();
            professorCertificates[recipient] = signatureHash;
            emit ProfessorCertificateIssued(recipient, signatureHash, block.timestamp);
        } else {
            Certs_Students studentDiploma = Certs_Students(payable(recipient));
            studentDiploma.emitt();
            studentCertificates[recipient] = signatureHash;
            emit StudentCertificateIssued(recipient, signatureHash, block.timestamp);
        }
    }
	event AdministratorAdded(address indexed adminAddress, uint256 date);

    function addAdministrator(address admin) public onlyOwner {
        require(admin != address(0), "Invalid administrator address");
        emit AdministratorAdded(admin, block.timestamp);
    }

    event StudentCertificateIssued(address student, bytes32 signatureHash, uint256 date);
    event ProfessorCertificateIssued(address professor, bytes32 signatureHash, uint256 date);

    function validateCertStudent(address diplomaAddress) public view returns (bool) {
        require(diplomaAddress != address(0), "Invalid diploma address");
        Certs_Students studentDiploma = Certs_Students(payable(diplomaAddress));
        return studentDiploma.isValid();
    }

    function validateCertProf(address diplomaAddress) public view returns (bool) {
        require(diplomaAddress != address(0), "Invalid diploma address");
        Certs_Profs professorDiploma = Certs_Profs(payable(diplomaAddress));
        return professorDiploma.isValid();
    }
}
