pragma solidity ^0.8.0;
import "./MC_Authority.sol";
import "./University.sol";
import "./TranscriptCert.sol";
import "./Certs_Profs.sol";
import "./Certs_Students.sol";
import "hardhat/console.sol";
import {SharedStructs} from "./Structs.sol";

contract Institution {


  address private owner;       // owner == Institution  
    uint private nb_semesters;  // number of semesters 
    uint private total;        // total number of semesters 
    MC_Authority private Autho; // instance of Sc authority 
    University d;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    mapping(address => SharedStructs.Student) private students;
    mapping(address => SharedStructs.Professor) private Professors;
    mapping(address => SharedStructs.Admin) private Admins;
    mapping(address => bool) public authorized;

    // Constructor owner == Dean of Institution 
    constructor(address autho, address univ, address UInstitution, address head) public {
        d = University(univ);
        Autho = MC_Authority(autho);
        require(univ != address(0x0) && UInstitution != address(0x0) && d.CheckInstitution(UInstitution) == true);
        owner = head;
    }

    modifier onlyAuthorized() {
        require(authorized[msg.sender] || owner == msg.sender, "Not authorized");
        _;
    }

    // Authorization management
    function addAuthorized(address _toAdd) public onlyOwner {
        require(_toAdd != address(0), "Invalid address");
        authorized[_toAdd] = true;
    }

    function removeAuthorized(address _toRemove) public onlyOwner {
        require(_toRemove != address(0), "Invalid address");
        require(_toRemove != msg.sender, "Cannot remove yourself");
        authorized[_toRemove] = false;
    }

    // Add entities (Student, Professor, Admin)
        event RegisteredSt(address from, address to, uint256 date);

  function AddStudent(address UInstitution, address student, bytes32 id) public onlyAuthorized {
    require(
        student != address(0) && !students[student].registered && UInstitution != address(0),
        "Invalid student or institution"
    );

    // Initialize the fields of the student struct manually
    students[student].id = id;
    students[student].registered = true;
    students[student].accomplished = 0;

    emit RegisteredSt(owner, student, block.timestamp);
}

     event RegisteredPr(address from, address to, uint256 date);
    function AddProfessor(address UInstitution, address professor, bytes32 id, bytes32 department) public onlyAuthorized {
        require(professor != address(0) && !Professors[professor].registered && UInstitution != address(0), "Invalid professor or institution");
        Professors[professor] = SharedStructs.Professor(true, professor, id, department);
         emit RegisteredPr(owner, professor, block.timestamp);
    }
      event RegisteredAd(address from, address to, uint256 date);
    function AddAdmin(address UInstitution, address admin, bytes32 id) public onlyAuthorized {
        require(admin != address(0) && !Admins[admin].registered && UInstitution != address(0), "Invalid admin or institution");
        Admins[admin] = SharedStructs.Admin(true, admin, id);
         emit RegisteredAd(owner, admin, block.timestamp);
    }


 // Function to issue a transcript for a student

   function issueTranscript(address student) internal {
        require(msg.sender == owner);
        TranscriptCert TrCert = new TranscriptCert(student, owner);
        TrCert.emitt();
		console.log("Transcript issued for student: ", student);

    }
	
	
 // Function to issue a diploma for a student

    function issueDiploma(address university, address student) internal onlyOwner {
     
        Certs_Students studentDiploma = new Certs_Students(student, university, owner);
        studentDiploma.emitt();
		console.log("Diploma issued for student: ", student);
    }
// Function to issue a diploma for a professor

    function issueDiplomaProf(address university, address student) internal onlyOwner {
     
        Certs_Profs professorDiploma = new Certs_Profs(student, university, owner);
        professorDiploma.emitt();
		console.log("Diploma issued for professor: ", professor);
    }


    // Deliberate a student's grade by a professor for a specific subject
    event GradeDeliberated(address student, address professor, uint256 modifiedNote, string material, uint256 date);

    function deliberate(address studentAddress, address professorAddress, uint256 modifiedNote, string memory material)
        public
        onlyAuthorized
    {
        require(Professors[professorAddress].registered, "Professor is not registered.");
        require(students[studentAddress].registered, "Student is not registered.");
        require(modifiedNote <= 100, "Modified note must be between 0 and 100.");

        // Update the student's grade for the specific material
        students[studentAddress].trans[keccak256(abi.encodePacked(material))].score = modifiedNote;

        // Emit an event for the grade deliberation
        emit GradeDeliberated(studentAddress, professorAddress, modifiedNote, material, block.timestamp);
    }

    // Add Transcript and Diploma handling
    event RegisteredTr(address from, address to, uint256 date);
    event totaled(address from, address to, bytes32 Degre, uint256 total, uint256 date);
    event Doc(address from, address to, bytes32 Degre, uint256 date);

    function issueDocDiploma(address university, address student, bytes32 Degre) public onlyOwner {
        require(student != address(0) && university != address(0), "Invalid addresses");

        if (Degre == 0x446f63746f726174000000000000000000000000000000000000000000000000) {
            issueDiploma(student, university);
            emit Doc(owner, student, Degre, block.timestamp);
        }
    }

    event ProfessorDoc(address from, address to, bytes32 Degre, uint256 date);

    function issueProfessorDiploma(address university, address professor, bytes32 Degre) public onlyOwner {
        require(professor != address(0) && university != address(0), "Invalid professor or university address");

        if (Degre == 0x50726f666573736f720000000000000000000000000000000000000000000000) {
            issueDiplomaProf(professor, university);
            emit ProfessorDoc(owner, professor, Degre, block.timestamp);
        }
    }

    function AddTranscript(address university, address student, bytes32 Degre, bytes32 Semstre, uint256 note)
        public
        onlyAuthorized
    {
        require(student != address(0) && university != address(0), "Invalid addresses");

        if (students[student].registered == true) {
            if (students[student].trans[Degre].Semstre == Semstre) {
                console.log("Transcript already exists");
            } else {
                students[student].trans[Degre] = SharedStructs.TranscriptCer({
                    issuer: owner,
                    receiver: student,
                    Degre: Degre,
                    Semstre: Semstre,
                    score: note,
                    date: block.timestamp,
                    note: note,
                    status: note >= 10
                });

                if (note >= 10) {
                    students[student].accomplished += 1;
                    total += note;
                    issueTranscript(student);
                    emit RegisteredTr(owner, student, block.timestamp);
                } else {
                    issueTranscript(student);
                    emit RegisteredTr(owner, student, block.timestamp);
                }

                // Degree == Deug
                if (Degre == 0x4465756700000000000000000000000000000000000000000000000000000000) {
                    nb_semesters = 4;

                    if (students[student].accomplished == nb_semesters) {
                        students[student].diploms[Degre] = SharedStructs.Acdiploma({
                            issuer_dean: owner,
                            issuer_president: owner,
                            receiver: student,
                            Degre: Degre,
                            date: block.timestamp,
                            note: total / nb_semesters,
                            status: true
                        });
                        emit totaled(owner, student, Degre, total / nb_semesters, block.timestamp);
                    } else {
                        console.log("The student has not validated the Diploma of General University Studies (DEUG) ");
                    }
                }
                // Degree == Licence
                else if (Degre == 0x4c6963656e636500000000000000000000000000000000000000000000000000) {
                    nb_semesters = 6;
                    if (students[student].accomplished == nb_semesters) {
                        students[student].diploms[Degre] = SharedStructs.Acdiploma({
                            issuer_dean: owner,
                            issuer_president: owner,
                            receiver: student,
                            Degre: Degre,
                            date: block.timestamp,
                            note: total / nb_semesters + students[student].diploms[Degre].note,
                            status: true
                        });
                        issueDiploma(student, university);
                        emit totaled(owner, student, Degre, students[student].diploms[Degre].note, block.timestamp);
                    } else {
                        console.log("The student has not validated the Diploma (Licence) ");
                    }
                }
                // Degree == Master
                else if (Degre == 0x4d61737465720000000000000000000000000000000000000000000000000000) {
                    nb_semesters = 4;
                    if (students[student].accomplished == nb_semesters) {
                        students[student].diploms[Degre] = SharedStructs.Acdiploma({
                            issuer_dean: owner,
                            issuer_president: owner,
                            receiver: student,
                            Degre: Degre,
                            date: block.timestamp,
                            note: total / nb_semesters + students[student].diploms[Degre].note,
                            status: true
                        });
                        issueDiploma(student, university);
                        emit totaled(owner, student, Degre, students[student].diploms[Degre].note, block.timestamp);
                    } else {
                        console.log("The student has not validated the Master's Degree ");
                    }
                }
            }
        }
    }



    // **Read Functions**

    // Get basic details of a student
    function getStudentBasicDetails(address student)
        public
        view
        returns (bytes32 id, bool registered, uint accomplished)
    {
        require(students[student].registered, "Student not registered");
        return (students[student].id, students[student].registered, students[student].accomplished);
    }

    // Get details of a specific transcript for a student
    function getStudentTranscript(address student, bytes32 degree)
        public
        view
        returns (
            address issuer,
            address receiver,
            bytes32 Degre,
            bytes32 Semstre,
            uint score,
            uint date,
            uint note,
            bool status
        )
    {
        require(students[student].registered, "Student not registered");
        SharedStructs.TranscriptCer memory transcript = students[student].trans[degree];
        return (
            transcript.issuer,
            transcript.receiver,
            transcript.Degre,
            transcript.Semstre,
            transcript.score,
            transcript.date,
            transcript.note,
            transcript.status
        );
    }

    // Get details of a specific diploma for a student
    function getStudentDiploma(address student, bytes32 degree)
        public
        view
        returns (
            address issuer_dean,
            address issuer_president,
            address receiver,
            bytes32 Degre,
            uint date,
            uint note,
            bool status
        )
    {
        require(students[student].registered, "Student not registered");
        SharedStructs.Acdiploma memory diploma = students[student].diploms[degree];
        return (
            diploma.issuer_dean,
            diploma.issuer_president,
            diploma.receiver,
            diploma.Degre,
            diploma.date,
            diploma.note,
            diploma.status
        );
    }

    // Get details of a professor
    function getProfessorDetails(address professor)
        public
        view
        returns (bool registered, address profAddress, bytes32 id, bytes32 department)
    {
        require(Professors[professor].registered, "Professor not registered");
        SharedStructs.Professor memory prof = Professors[professor];
        return (prof.registered, prof.Professor, prof.id, prof.Department);
    }

    // Get details of an admin
    function getAdminDetails(address admin) public view returns (bool registered, address adminAddress, bytes32 id) {
        require(Admins[admin].registered, "Admin not registered");
        SharedStructs.Admin memory adminData = Admins[admin];
        return (adminData.registered, adminData.Admin, adminData.id);
    }

    // Check if a student is registered
    function isStudentRegistered(address student) public view returns (bool) {
        return students[student].registered;
    }

    // Check if a professor is registered
    function isProfessorRegistered(address professor) public view returns (bool) {
        return Professors[professor].registered;
    }

    // Check if an admin is registered
    function isAdminRegistered(address admin) public view returns (bool) {
        return Admins[admin].registered;
    }

    // Get authorized status of an address
    function isAuthorized(address user) public view returns (bool) {
        return authorized[user];
    }

    // Function to get the total number of semesters
    function getTotalSemesters() public view returns (uint256) {
        return total;
    }
}

