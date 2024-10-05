//pragma solidity >=0.7.0 <0.9.0;
pragma solidity ^0.4.23;

import "./MC_Authority.sol";
import {SharedStructs} from "./Structs.sol";
//import "./AcDiploma.sol";
import "./Certs_Profs.sol";
import "./Certs_Students.sol";

contract University {
    address private owner; // owner == University
    MC_Authority private Autho; // instance of Sc authority
    uint private nb_semesters; // number of semesters
    uint private total; // total number of semesters

    modifier onlyOwner {
        require(msg.sender == owner);
        require(Autho.isCertificateValid(owner));
        _;
    }

    mapping(address => SharedStructs.U_institution) private Institutions;

    // Mappings for certificates with hashed signatures (barcode data)
    mapping(address => bytes32) public studentCertificates; // stores student certificates with signature hashes
    mapping(address => bytes32) public professorCertificates; // stores professor certificates with signature hashes

    // Constructor where owner == head of university
    constructor(address autho, address university) public {
        require(university != address(0x0) && autho != address(0x0));

        Autho = MC_Authority(autho);
        owner = university;
    }

    // Event for registering an institution
    event RegisteredIn(address from, address to, uint date);

    // Add Institution to the blockchain by onlyOwner, which is a university approved by CA
    function AddInstitution(address Institution, address head, address vice_head) public onlyOwner {
        require(Institution != address(0x0) && !Institutions[Institution].registered);
        Institutions[Institution].registered = true;
        Institutions[Institution].head = head;
        Institutions[Institution].vice_head = vice_head;
        emit RegisteredIn(owner, Institution, block.timestamp);
    }

    // Check Institution registration status
    function CheckInstitution(address ins) public view returns (bool) {
        require(ins != address(0x0));

        return Institutions[ins].registered;
    }

    // Internal function to issue a diploma with a hashed signature (barcode data) for student or professor
    function issueDiplomaP(address Uinstitution, address recipient, bool isProfessor) internal onlyOwner {
        require(Uinstitution != address(0x0) && CheckInstitution(Uinstitution) == true, "Invalid institution");
        require(recipient != address(0x0), "Invalid recipient address");

        // Issue a diploma to the recipient (student or professor)
        //AcDiploma diploma = new AcDiploma(recipient, Uinstitution, owner);
        //Certs_Students diploma = new Certs_Students(recipient, Uinstitution, owner);
        //diploma.emitt();

        // Generate a unique hash (barcode data) for the recipient's certificate using the owner's signature
        bytes32 signatureHash = keccak256(abi.encodePacked(recipient, Uinstitution, owner, block.timestamp));

        if (isProfessor) {
        Certs_Profs professorDiploma = new Certs_Profs(recipient, Uinstitution, owner);
        professorDiploma.emitt();
            // Store the signature hash in the professorCertificates mapping
            professorCertificates[recipient] = signatureHash;
        } else {
        Certs_Students studentDiploma = new Certs_Students(recipient, Uinstitution, owner);
        studentDiploma.emitt();
            // Store the signature hash in the studentCertificates mapping
            studentCertificates[recipient] = signatureHash;
        }

        // Emit the event based on the type of recipient
        if (isProfessor) {
            emit ProfessorCertificateIssued(recipient, signatureHash, block.timestamp);
        } else {
            emit StudentCertificateIssued(recipient, signatureHash, block.timestamp);
        }
    }

    // Event for student certificate issuance
    event StudentCertificateIssued(address student, bytes32 signatureHash, uint date);

    // Event for professor certificate issuance
    event ProfessorCertificateIssued(address professor, bytes32 signatureHash, uint date);

    // Function to sign and issue a student's certificate with barcode-style signature
    function signStudentCertificate(address student) public onlyOwner {
        issueDiplomaP(owner, student, false);
    }

    // Function to sign and issue a professor's certificate with barcode-style signature
    function signProfessorCertificate(address professor) public onlyOwner {
        issueDiplomaP(owner, professor, true);
    }

    // Function to add a university administrator
    event AdministratorAdded(address adminAddress, uint date);

    function addAdministrator(address admin) public onlyOwner {
        require(admin != address(0x0), "Invalid administrator address");
        emit AdministratorAdded(admin, block.timestamp);
    }

    // Function to validate an academic certification
    function validateCertStudent(address diplomaAddress) public view returns (bool) {
        require(diplomaAddress != address(0x0), "Invalid diploma address");
        Certs_Students studentDiploma  = Certs_Students(diplomaAddress);
        return studentDiploma.isValid();
    }


       function validateCertProf(address diplomaAddress) public view returns (bool) {
        require(diplomaAddress != address(0x0), "Invalid diploma address");
        Certs_Profs professorDiploma  = Certs_Profs(diplomaAddress);
        return professorDiploma.isValid();
    }

    // Function to check a student's certificate signature (barcode data)
    function checkStudentCertificateSignature(address student) public view returns (bytes32) {
        require(student != address(0x0), "Invalid student address");
        return studentCertificates[student];
    }

    // Function to check a professor's certificate signature (barcode data)
    function checkProfessorCertificateSignature(address professor) public view returns (bytes32) {
        require(professor != address(0x0), "Invalid professor address");
        return professorCertificates[professor];
    }
}
